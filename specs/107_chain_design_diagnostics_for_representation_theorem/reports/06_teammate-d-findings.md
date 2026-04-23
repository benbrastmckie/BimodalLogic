# Teammate D (Horizons): Strategic Path Recommendation

**Task**: 107 - Chain design diagnostics for representation theorem
**Round**: 6
**Angle**: Strategic recommendation on optimal path to representation theorem
**Date**: 2026-04-23

## Executive Summary

After analyzing all four paths, the ROADMAP, Burgess 1982, the axiom system, Truth.lean, TaskFrame.lean, and the codebase infrastructure, I recommend **Path 3 (Strict G/H + full Burgess) as the primary path**, with a phased approach that delivers a sorry-free representation theorem for a Box+G+H fragment first, then extends to Until/Since via direct Burgess adoption.

The key insight is that Path 3 collapses two separate problems (the irreducible Lindenbaum obstruction AND the axiom derivation gate) into one coherent solution: adopt Burgess's semantics AND his axioms, making his proof directly applicable.

---

## Path Analysis

### Path 1: Strict G/H, Box+G+H Only First

**What it entails**:
- Change Truth.lean: G uses `t < s` instead of `t <= s`, H uses `s < t` instead of `s <= t`
- Drop BX1/BX1' (temp_t_future/past), BX8/BX8', BX9/BX9'
- Keep temp_k_dist, temp_4, BX4/BX4', BX11/BX11'
- Add the derived T-axiom for strict: `phi -> G(F(phi))` (already BX4)
- Prove representation theorem for S5 + Kt.4 (standard Kripke semantics)
- Until/Since deferred to later phase

**Effort estimate for Box+G+H representation theorem**: 30-50 hours
- The canonical model construction for S5+Kt.4 is well-understood
- bx_le becomes strict (`g_content w propersubset v.formulas`), no reflexivity needed
- The F-propagation problem (the irreducible Lindenbaum obstruction from task 93) disappears: without Until/Since, there are no eventuality formulas requiring chain witnesses
- G/H truth lemma is straightforward: G-forward via g_content inclusion, H-backward via connect_future/connect_past
- Modal S5 truth lemma already sorry-free

**Lines affected by semantic change**: ~248 references to BX8/BX9/temp_t outside Boneyard, but most are in Soundness.lean (case arms in exhaustive pattern matches) and TemporalDerived.lean (derived theorems). The actual proof-critical changes are concentrated in:
- Truth.lean: 2 lines (change `<=` to `<` for G/H)
- Axioms.lean: Remove 4 axiom constructors (BX1, BX1', BX8/BX8', BX9/BX9' = 6 constructors)
- Soundness.lean: Remove corresponding soundness cases
- All files matching on Axiom constructors: update exhaustive matches

**Risk**: Medium. The semantic change is well-defined but touches many files. The Box+G+H-only theorem is mathematically simple. The risk is in the later Until/Since extension.

**Advantage**: Delivers a real, sorry-free representation theorem FAST. Establishes the infrastructure pattern (TaskModel from canonical frame) that Until/Since can reuse.

### Path 2: Keep Reflexive, Fix Chain for U/S

**What it entails**:
- No semantic change
- Derive A3a and A4a from BX1-BX12 (the gate condition)
- Implement Burgess chronicle construction adapted for reflexive Until
- Close all 5 sorry sites in RootScopedChain.lean

**Effort estimate**: 105-155 hours (from round 5 synthesis), with 60% confidence on the axiom gate

**Critical gate (A3a derivability)**:
- A3a: `p AND U(q, r) -> U(q AND S(p, r), r)`
- Under reflexive semantics, this connects Until and Since across the current point
- Derivation attempt path: BX4 gives `p -> G(P(p))`, so at any future time s where `r` holds and `q` holds, we need `S(p, r)` at s. Under reflexive Since, `S(p,r)` at s means there exists `u <= s` with `p` at u and `r` on (u, s]. If s = t (the current time), `S(p,r)` reduces to `p` (by BX8' mirror), which holds. If s > t, we need `p` at t and `r` on (t, s]. The guard content of `U(q, r)` gives `r` on [t, s) under reflexive semantics (actually `q` on [t,s)), not `r`. This is NOT the right guard direction.
- **Assessment**: A3a is UNLIKELY to be derivable from BX1-BX12 under reflexive semantics. The axiom connects Until and Since in a way that requires strict semantics to make sense. Under reflexive semantics, BX8 trivializes the temporal witness, breaking the S(p,r) connection.

**A4a derivability**:
- A4a: `U(p, q) AND NOT U(p, r) -> U(q AND NOT r, q)`
- This decomposes an Until when another Until with different right argument fails
- Assessment: More plausible to derive using BX7 (linearity) but would require careful case analysis. Still uncertain.

**Risk**: HIGH. The 60% gate probability was already generous. My analysis above suggests A3a derivability is lower, perhaps 30-40%. If the gate fails, 4-6 hours of derivation attempt are wasted, and the project must fall back to a different approach.

**Advantage**: No semantic change, backward compatible.

### Path 3: Strict G/H + Keep U/S + Full Burgess (RECOMMENDED)

**What it entails**:
- Change Truth.lean: G/H to strict (`<` instead of `<=`), Until/Since stay as-is but change to strict witness (`t < s` instead of `t <= s`)
- Drop BX1/BX1' (temp_t), BX8/BX8' (refl_intro), BX9/BX9' (until_elim)
- Adopt Burgess's A1a-A7a directly as axioms (they ARE the strict system)
- BX2-BX7 map directly to A1a, A2a, A5a-A7a
- A3a and A4a become axioms (not derived)
- BX10, BX11, BX12 remain (BX10 = derived from A-axioms, BX11 = A7a for F, BX12 = bridge)
- Implement Burgess chronicle construction DIRECTLY (no adaptation needed)

**Effort estimate**: 80-120 hours total, broken into two phases:
- Phase A (semantic + axiom change): 20-30 hours
  - Truth.lean: Change G/H/U/S to strict
  - Axioms.lean: Replace BX1/BX1'/BX8/BX8'/BX9/BX9' with A3a/A4a
  - Soundness.lean: Prove soundness of new axioms (routine)
  - Fix exhaustive matches throughout (~30 files)
  - Recheck sorry-free modules (TruthLemma, Frame, Quasimodel may need updates)
- Phase B (Burgess construction): 60-90 hours
  - Chronicle type definition (f: Q -> MCS, g: Q x Q -> DCS)
  - Lemmas 2.2-2.8 (r-relation, R-maximality, consistency criteria, point insertion)
  - Counterexample elimination (Lemmas 2.9-2.10)
  - Omega-union and model construction
  - TaskModel embedding and truth lemma bridge
  - Close all 5 sorry sites

**Key mathematical advantage**: Burgess's proof is DIRECTLY applicable. No axiom derivation gate. No adaptation for reflexive semantics. The proof in the paper was designed for strict semantics with A1a-A7a. We would be implementing the exact construction.

**Risk**: LOW-MEDIUM. The semantic change is larger than Path 1, but the mathematical proof is a known quantity. Burgess's construction has been peer-reviewed for 44 years. The main risk is implementation complexity in Lean 4 (binary interval functions, rational-indexed chronicles, omega-unions).

**What about existing sorry-free infrastructure?**
- Frame.lean (673 lines): bx_le uses g_content, which works with strict G. The reflexivity proof (bx_le_refl) would fail, but under strict semantics bx_le becomes a strict preorder (irreflexive, transitive). This is actually BETTER because Burgess's proof uses strict ordering.
- TruthLemma.lean (320 lines): The Until/Since cases use BX8/BX9, which would be dropped. These cases need rewriting to use A3a/A4a instead. The Box/G/H cases are largely unaffected (G now uses `<` but the canonical ordering argument is the same modulo reflexivity).
- Quasimodel/ (1,816 lines): The defect-discharge machinery was designed for the old chain approach. Much of it may not be needed under the Burgess chronicle approach. However, the sigma-closure and Hintikka point infrastructure could be reused for the finite-closure bound.
- RootScopedChain.lean (1,681 lines, 5 sorries): This entire module would be REPLACED by the Burgess chronicle construction. The 5 sorry sites would be resolved not by fixing them but by implementing a different proof strategy.

### Path 4: Dual Operator System

**What it entails**:
- Keep reflexive G/H for backward compatibility
- Add new strict G'/H' operators as new Formula constructors
- Prove representation for the strict operators
- Derive: G(phi) iff phi AND G'(phi)

**Effort estimate**: 150+ hours

**Risk**: HIGH. Adding new Formula constructors is a massive change (Formula is the core type used everywhere). Every pattern match on Formula needs new cases. The interplay between reflexive and strict operators creates a combinatorial explosion in the axiom system and soundness proofs.

**Assessment**: This is over-engineering. If the user prefers strict semantics philosophically (which they do), there is no reason to maintain a dual system. The reflexive operators can be DEFINED from strict ones: `G(phi) := phi AND G'(phi)`. This definition is derivable, not a new primitive.

---

## ROADMAP and Historical Context

### What the ROADMAP says about strict vs reflexive

The ROADMAP (lines 33, 551-554) documents:
- "Legacy strict-semantics files" (107 sorries) were archived to `Boneyard/StrictSemanticsLegacy/` in task 94
- The codebase PREVIOUSLY used strict semantics, then switched to reflexive
- The strict semantics legacy code exists in the Boneyard (BaseCompleteness.lean, DiscreteCompleteness.lean, DenseCompleteness.lean, etc.)
- The switch to reflexive was motivated by the BX axiom system's compatibility with reflexive G/H (BX1 requires it)

This is significant: **the project already had strict semantics infrastructure and switched away from it**. The switch was driven by the axiom system design, not by a philosophical commitment to reflexive semantics. If we adopt Burgess's axioms directly, the original motivation for reflexive semantics disappears.

### Tasks 74-76 and strict temporal extensions

These tasks are referenced in the ROADMAP but are not in the active task cross-reference table. They appear to be early-stage research tasks that predated the BX axiom system adoption. The connection is historical: the project has always considered strict temporal operators but chose reflexive for axiom-system reasons.

### The irreducible Lindenbaum obstruction

The ROADMAP documents 36 dead ends (!) stemming from the same root cause: Lindenbaum extension via `Classical.choose` is opaque, preventing control over what goes into successor MCS points. This obstruction has consumed enormous effort and is SPECIFIC to the chain-based construction used under reflexive semantics. Burgess's construction avoids this entirely by:
1. Using binary interval functions g(x,y) instead of unary g_content(M)
2. Using direct point insertion (Lemma 2.4) instead of BX11 fold
3. Building over Q (dense) with midpoint insertion instead of Z (discrete)

---

## The User's Philosophical Position

The user states: "PREFERS irreflexive (strict) G/H -- more expressively powerful."

This is mathematically correct:
- Under strict G, we can express "phi holds at all future times but not now" as `G(phi) AND NOT phi`
- Under reflexive G, `G(phi)` implies `phi`, so `G(phi) AND NOT phi` is unsatisfiable
- Strict G distinguishes three things: phi now, G(phi) (phi at all strict future), and `phi AND G(phi)` (phi now and forever)
- Reflexive G conflates the last two: `phi AND G(phi) iff G(phi)` under reflexive semantics

The user's preference aligns perfectly with Path 3: adopt strict semantics and get a more expressive logic with a well-known complete axiomatization.

---

## Strategic Recommendation

### Primary Recommendation: Path 3 (Strict + Full Burgess), phased

**Phase 0: Box+G+H Fragment (8-15 hours)**
Before touching Until/Since, prove a representation theorem for the Box+G+H fragment under strict semantics. This is mathematically the simplest case (standard S5 + Kt.4 completeness) and:
- Validates the semantic change end-to-end
- Establishes the TaskModel embedding pattern
- Delivers a sorry-free result quickly
- Builds confidence before the harder Until/Since construction

**Phase 1: Semantic and Axiom Change (20-30 hours)**
- Truth.lean: G/H to strict, Until/Since to strict
- Axioms.lean: Drop BX1/BX1', BX8/BX8', BX9/BX9'; add A3a, A4a
- Soundness.lean: Prove new axioms sound
- Fix exhaustive matches (~30 files)
- Verify TruthLemma, Frame, Quasimodel still compile (with updates)

**Phase 2: Burgess Chronicle Infrastructure (25-35 hours)**
- Chronicle type: `(f : Q -> MCS, g : Q x Q -> DCS)` with conditions C0-C3
- r-relation definition and properties (Lemma 2.3)
- R-maximality (Lemma 2.5)
- Point insertion (Lemma 2.4 -- the mathematical heart)

**Phase 3: Counterexample Elimination (20-30 hours)**
- Lemma 2.6 (non-membership point insertion)
- Lemma 2.7 (Until witness point insertion)
- Lemma 2.8 (Until propagation failure repair)
- Lemma 2.9 (C4a counterexample elimination)
- Lemma 2.10 (C5a counterexample elimination)

**Phase 4: Omega-Union and Integration (15-20 hours)**
- Omega-union of (f_n, g_n) sequence
- Valuation and truth claim (Claim 2.11)
- TaskModel embedding
- Bridge to bx_completeness

**Total**: 88-130 hours, with high confidence (85%+) of success.

### Comparison Table

| Criterion | Path 1 | Path 2 | Path 3 | Path 4 |
|-----------|--------|--------|--------|--------|
| Effort to first sorry-free theorem | 30-50h | 105-155h | 40-65h (Phase 0+1) | 150+h |
| Total effort to full completeness | 130-200h | 105-155h | 88-130h | 200+h |
| Gate risk | None | 60% A3a/A4a | None | None |
| Matches user preference (strict) | Yes (G/H only) | No | Yes (all operators) | Partially |
| Uses proven construction | Yes (standard) | Adapted | Yes (Burgess 1982) | Novel |
| Codebase disruption | Medium | Low | High (one-time) | Very High |
| Existing infrastructure reuse | Partial | Full | Partial-to-full | Minimal |
| Mathematical confidence | 95% | 60% (gate), 80% if gate passes | 90% | 70% |
| Philosophical expressiveness | Partial (no U/S) | No gain | Full | Redundant |

### Why Not Path 2?

Path 2 is the conservative option, but it faces two compounding risks:
1. The A3a/A4a derivation gate (estimated 30-40% success by my analysis)
2. Even if the gate passes, the Burgess construction must be ADAPTED for reflexive Until semantics -- this is an unpublished adaptation with unknown difficulty

The project has already spent enormous effort (36 dead ends documented) trying to make the chain construction work under reflexive semantics. The Lindenbaum opacity obstruction is fundamental to the reflexive approach. Path 3 sidesteps this entirely.

### Why Not Path 1 alone?

Path 1 gets a theorem quickly but leaves Until/Since as a separate (and potentially harder) problem. With Path 3, the Until/Since representation theorem follows directly from Burgess's proof because we are using his exact system.

### TaskFrame Invariance

**CRITICAL**: The user specifies that TaskFrame.lean MUST NOT change. This is satisfied by all paths. TaskFrame defines the semantic target (world states, task relations, compositionality). The temporal ordering on D is independent of TaskFrame -- it comes from the LinearOrder and AddCommGroup instances on D. Changing G/H from reflexive to strict only affects Truth.lean (how formulas are evaluated relative to the ordering), not TaskFrame.lean (which defines the frame structure).

---

## Risk Mitigation

### Risk 1: Semantic change breaks too much code
**Mitigation**: Phase 0 (Box+G+H fragment) validates the change with minimal disruption. If breakage is unexpectedly severe, we can assess before committing to Until/Since.

### Risk 2: Burgess construction is harder in Lean than expected
**Mitigation**: The construction uses only standard tools (MCS extension, Lindenbaum's lemma, rational midpoint insertion). The project already has `set_lindenbaum` (sorry-free). The novel piece is the binary g(x,y) function, which is a clean functional abstraction.

### Risk 3: Existing sorry-free modules break
**Mitigation**: The Quasimodel/ infrastructure (1,816 lines) may break because it relies on BX8/BX9. However, under the Burgess approach, the Quasimodel infrastructure is NOT NEEDED for the main completeness proof. It can be archived to Boneyard (like the strict semantics legacy was) or adapted later.

### Risk 4: Q-indexed construction doesn't match Z-indexed BFMCS
**Mitigation**: The ParametricRepresentation.lean is parametric over D. It accepts any totally ordered abelian group. Using Q instead of Z is a matter of instantiation, not refactoring. The Q-indexed chronicle naturally maps to a TaskModel over Q.

---

## Appendix: Axiom Correspondence

### Burgess A-axioms to BX-axioms mapping

| Burgess | BX Equivalent | Status under strict |
|---------|---------------|---------------------|
| A1a | BX2 (left_mono_until) | Keep |
| A2a | BX3 (right_mono_until) | Keep |
| A3a | NEW (no BX equivalent) | Add as axiom |
| A4a | NEW (no BX equivalent) | Add as axiom |
| A5a | BX5 (self_accum_until) | Keep |
| A6a | BX6 (absorb_until) | Keep |
| A7a | BX7 (linear_until) | Keep |

### BX axioms to drop under strict

| BX | Reason for dropping |
|----|---------------------|
| BX1 (temp_t_future) | Requires reflexive G, invalid under strict |
| BX1' (temp_t_past) | Requires reflexive H, invalid under strict |
| BX8 (refl_intro_until) | Requires reflexive Until witness (s=t), invalid under strict |
| BX8' (refl_intro_since) | Mirror |
| BX9 (until_elim) | Requires reflexive Until, invalid under strict |
| BX9' (since_elim) | Mirror |

### BX axioms that stay (or need minor adjustment)

| BX | Status |
|----|--------|
| temp_k_dist | Keep (G-distribution valid under strict) |
| temp_4 | Keep (G-transitivity valid under strict) |
| BX2-BX7 and mirrors | Keep (all valid under strict) |
| BX10/BX10' | Keep (eventuality extraction valid under strict) |
| BX11/BX11' | Keep (linearity valid under strict) |
| BX12/BX12' | Keep (F-Until bridge valid under strict) |
| modal_future, temp_future | Keep (interaction axioms valid under strict) |

---

## Conclusion

**Path 3 (Strict + Full Burgess) is optimal** because it:
1. Aligns with the user's stated preference for strict semantics
2. Eliminates the A3a/A4a derivation gate entirely (they become axioms)
3. Makes Burgess's 44-year-old peer-reviewed construction directly applicable
4. Sidesteps the 36-dead-end Lindenbaum opacity problem
5. Delivers a phased result: Box+G+H fragment fast, then full completeness
6. Does NOT require changing TaskFrame.lean
7. Has the highest mathematical confidence (90%) at reasonable effort (88-130h)

The one-time cost of the semantic change (~20-30 hours) is an investment that resolves the fundamental architectural mismatch identified in round 5: the project has been trying to make a reflexive chain construction do something that Burgess's strict chronicle construction does naturally.
