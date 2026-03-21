# Research Report: Task #658

**Task**: Prove indexed family coherence conditions
**Date**: 2026-01-25
**Focus**: Four coherence condition sorries in IndexedMCSFamily.lean

## Summary

This research analyzed the four coherence condition sorries in the `construct_indexed_family` function (lines 433, 439, 448, 456 of IndexedMCSFamily.lean). These conditions ensure that the indexed MCS family satisfies temporal coherence requirements matching TM logic's irreflexive temporal semantics. The sorries have clear proof strategies documented in comments, but require careful case analysis using temporal axioms (particularly Temporal 4 and Temporal K distribution).

## Context & Scope

### Background: Indexed MCS Family Approach

The indexed MCS family solves a fundamental problem in the universal parametric canonical model construction:
- **Problem**: Previous approaches required temporal T-axioms (`G phi -> phi`, `H phi -> phi`) that TM logic does NOT have
- **Solution**: Build a family of MCS indexed by time points, where each time has its own MCS connected via coherence conditions
- **Key Insight**: Coherence conditions use STRICT inequalities (< not ≤), matching irreflexive temporal operators G ("strictly future") and H ("strictly past")

### The Four Coherence Conditions

The `IndexedMCSFamily` structure requires four coherence fields:

1. **forward_G**: `G phi ∈ mcs(t) → phi ∈ mcs(t')` for `t < t'` (strictly future)
2. **backward_H**: `H phi ∈ mcs(t) → phi ∈ mcs(t')` for `t' < t` (strictly past)
3. **forward_H**: `H phi ∈ mcs(t') → phi ∈ mcs(t)` for `t < t'` (looking back from future)
4. **backward_G**: `G phi ∈ mcs(t') → phi ∈ mcs(t)` for `t' < t` (looking forward from past)

### Construction Strategy

The `construct_indexed_family` function builds a family from a root MCS at the origin (time 0):

1. **At origin (t = 0)**: Use the given MCS directly
2. **Future times (t > 0)**: Seed with `{phi | G phi ∈ origin}`, extend via Lindenbaum
3. **Past times (t < 0)**: Seed with `{phi | H phi ∈ origin}`, extend via Lindenbaum

The coherence conditions must then be proven for this construction.

## Findings

### 1. Forward G Coherence (Line 433)

**Goal**: Prove `G phi ∈ mcs(t) → phi ∈ mcs(t')` for `t < t'`

**Proof Strategy** (from code comments):
Three case analysis based on time position:

**Case 1: t = 0 (origin)**
- If `G phi ∈ mcs(0) = extended Gamma` and `0 < t'`
- Then `phi` is in `future_seed` at `t'` by definition (line 279-281)
- Since `mcs(t')` extends the seed (lemma `mcs_at_time_contains_seed`, line 388-390)
- Therefore `phi ∈ mcs(t')`

**Case 2: t > 0 (future time)**
- If `G phi ∈ mcs(t)` for some `t > 0`, need to show `phi ∈ mcs(t')` for `t < t'`
- This requires using **Temporal 4 axiom**: `G phi → GG phi` (Axiom.temp_4, line 218-219)
- From `G phi ∈ mcs(0)`, we have `GG phi ∈ mcs(0)` (by axiom membership in MCS)
- Therefore `G phi` is in the future_seed at all `t' > 0`
- By transitivity, `phi` is in the seed at all `t'' > t' > 0`

**Case 3: t < 0 (past time)**
- Similar analysis using temporal axiom propagation
- Need to track how G formulas propagate from past through origin to future

**Key Lemmas Needed**:
- `theorem_in_mcs`: Theorems (derivable formulas) are in every MCS (already available, line 203-206)
- Temporal 4 axiom instance: `Axiom.temp_4` (available in ProofSystem/Axioms.lean:218-219)
- `extendToMCS_contains`: Extended MCS contains seed (available, line 232-235)
- `mcs_at_time_contains_seed`: MCS at time t contains time_seed (available, line 388-390)

**Estimated Difficulty**: Medium. Requires careful case analysis but proof strategy is clear.

### 2. Backward H Coherence (Line 439)

**Goal**: Prove `H phi ∈ mcs(t) → phi ∈ mcs(t')` for `t' < t`

**Proof Strategy** (from code comments):
Symmetric to forward_G but using H (all_past) instead of G (all_future).

**Case 1: t = 0 (origin)**
- If `H phi ∈ mcs(0)` and `t' < 0`
- Then `phi` is in `past_seed` at `t'` by definition (line 287-290)
- Therefore `phi ∈ mcs(t')`

**Case 2: t < 0 (past time)**
- Use temporal H duality axiom (derived from temporal_duality rule, line 136-137)
- Similar to forward_G case 2 but in reverse temporal direction

**Case 3: t > 0 (future time)**
- Track H formulas propagating from future through origin to past

**Key Lemmas Needed**:
- Same as forward_G but for past direction
- Temporal duality: `DerivationTree.temporal_duality` (available, line 136-137)
- Swap formulas to convert between past and future forms

**Estimated Difficulty**: Medium. Symmetric to forward_G once the pattern is understood.

### 3. Forward H Coherence (Line 448)

**Goal**: Prove `H phi ∈ mcs(t') → phi ∈ mcs(t)` for `t < t'`

**Proof Strategy** (from code comments):
"Looking back from the future" condition - if at future time t' we have H phi (always true in past), then phi must be true at earlier time t.

**Case Analysis**:

**Case 1: t' > 0, t = 0**
- If `H phi ∈ mcs(t')` where `t' > 0` and we want `phi ∈ mcs(0)`
- Need to use the fact that if H phi was placed in future_seed, it came from somewhere
- Actually, H phi at t' > 0 is NOT guaranteed by the seed construction
- This is the harder direction - requires proving a property NOT directly from seeds

**Case 2: t' > 0, t > 0**
- Both in future, need `t < t'`
- If `H phi ∈ mcs(t')`, we need `phi ∈ mcs(t)`
- This requires understanding H semantics: "phi at all strictly past times"

**Case 3: t' > 0, t < 0**
- Even harder: future time looking back to past time through origin

**Key Insight**:
This direction is NOT seed-propagation - it's semantic coherence. The proof likely requires:
1. Contrapositive reasoning: assume `phi ∉ mcs(t)`
2. Use MCS maximality to get `¬phi ∈ mcs(t)` (via `CanonicalWorld.neg_complete`, line 95-116)
3. Show this contradicts `H phi ∈ mcs(t')` for `t < t'`
4. Use temporal axioms about H propagation

**Key Lemmas Needed**:
- `CanonicalWorld.neg_complete`: MCS negation completeness (has sorry at line 116)
- Temporal axiom relating H and negation
- Possibly temporal A axiom: `phi → F(sometime_past phi)` (Axiom.temp_a, line 228-229)

**Estimated Difficulty**: High. This is the "backward" direction not directly constructible from seeds. Requires deep understanding of temporal coherence semantics.

### 4. Backward G Coherence (Line 456)

**Goal**: Prove `G phi ∈ mcs(t') → phi ∈ mcs(t)` for `t' < t`

**Proof Strategy** (from code comments):
"Looking forward from the past" condition - if at past time t' we have G phi (always true in future), then phi must be true at later time t.

**Case Analysis**:

**Case 1: t' < 0, t = 0**
- If `G phi ∈ mcs(t')` where `t' < 0` and we want `phi ∈ mcs(0)`
- Need to reason about what G formulas at past times imply for origin

**Case 2: t' < 0, t < 0**
- Both in past, need `t' < t < 0`
- Use temporal axioms for G propagation

**Case 3: t' < 0, t > 0**
- Past time looking forward to future through origin
- Hardest case: crosses temporal origin

**Key Insight**:
Similar to forward_H - this is semantic coherence, not seed construction. Likely proof pattern:
1. Assume `phi ∉ mcs(t)`
2. Get `¬phi ∈ mcs(t)` by MCS maximality
3. Show contradiction with `G phi ∈ mcs(t')` for `t' < t`
4. Use Temporal 4 and transitivity

**Key Lemmas Needed**:
- Same as forward_H
- Temporal 4 for G transitivity
- Understanding of how G formulas propagate forward in time

**Estimated Difficulty**: High. Symmetric to forward_H in complexity.

### 5. Seed Consistency Proofs (Lines 338, 354)

While not part of the four coherence conditions, the seed consistency proofs are mentioned in Task 654 review (line 115-117) and are prerequisites for the construction:

**future_seed_consistent (line 338)**:
Proof idea documented in comments (lines 311-320):
- If future_seed were inconsistent, some finite subset would derive bot
- But then {G phi_1, ..., G phi_n} would derive G bot by temporal K distribution
- G bot → bot is derivable (vacuous), contradicting root MCS being consistent

**past_seed_consistent (line 354)**:
Symmetric proof using H instead of G

**Key Axiom Needed**:
- `Axiom.temp_k_dist`: Temporal K distribution `F(φ → ψ) → (Fφ → Fψ)` (line 210-211)
- This is the key axiom that makes the seed consistency proofs work

## Dependencies

### Available Lemmas

From `MaximalConsistent.lean`:
- `theorem_in_mcs`: Theorems in every MCS (line 49)
- `set_lindenbaum`: Lindenbaum's lemma (line 38)
- `maximal_consistent_closed`: MCS deductive closure (line 47)

From `CanonicalWorld.lean`:
- `extendToMCS`: Extend consistent set to MCS (line 227-228)
- `extendToMCS_contains`: Extension contains original (line 232-235)
- `extendToMCS_is_mcs`: Extension is MCS (line 240-242)
- `CanonicalWorld.neg_complete`: MCS negation completeness (line 95, has sorry at 116)
- `CanonicalWorld.deductively_closed`: Deductive closure (line 123, has sorry at 163)
- `CanonicalWorld.modus_ponens_closure`: MP closure (line 181-198, complete)

From `IndexedMCSFamily.lean`:
- `mcs_at_time_contains_seed`: MCS contains seed (line 388-390)
- `mcs_at_time_is_mcs`: MCS is maximal consistent (line 395-397)
- `future_seed`, `past_seed`, `time_seed`: Seed definitions (lines 279-303)

From `ProofSystem/Axioms.lean`:
- `Axiom.temp_4`: Temporal 4 axiom `Fφ → FFφ` (line 218-219)
- `Axiom.temp_k_dist`: Temporal K distribution (line 210-211)
- `Axiom.temp_a`: Temporal A axiom `φ → F(sometime_past φ)` (line 228-229)
- `Axiom.temporal_duality`: Swap past/future (available via DerivationTree, line 136-137)

### Missing Prerequisites

**Critical blockers**:
1. `CanonicalWorld.neg_complete` has a sorry (line 116)
   - Needed for contrapositive reasoning in forward_H and backward_G
   - Proof strategy noted: use set-based MCS properties and deduction theorem

2. `CanonicalWorld.deductively_closed` has a sorry (line 163)
   - Needed for combining derivations in coherence proofs
   - Proof strategy noted: proper derivation combination using weakening and deduction theorem

**Workaround**: The coherence conditions might be provable WITHOUT these lemmas if we use direct seed membership arguments, but forward_H and backward_G appear to genuinely need negation completeness for the contrapositive approach.

## Proof Strategies

### Recommended Order

1. **Complete seed consistency proofs** (lines 338, 354)
   - Relatively self-contained
   - Uses temporal K distribution axiom
   - Provides foundation for understanding temporal propagation
   - Effort: 6-8 hours

2. **Prove forward_G** (line 433)
   - Most direct from seed construction
   - Uses Temporal 4 axiom
   - Good learning case for the case analysis pattern
   - Effort: 3-4 hours

3. **Prove backward_H** (line 439)
   - Symmetric to forward_G
   - Reinforces the pattern
   - Effort: 2-3 hours

4. **Fix CanonicalWorld.neg_complete** (CanonicalWorld.lean:116)
   - Prerequisite for forward_H and backward_G
   - Uses set-based MCS theory
   - Effort: 4-5 hours

5. **Prove backward_G** (line 456)
   - Uses negation completeness
   - Transitivity reasoning
   - Effort: 4-5 hours

6. **Prove forward_H** (line 448)
   - Most complex
   - Uses negation completeness and temporal A axiom
   - Effort: 4-5 hours

**Total estimated effort**: 23-30 hours for all six sorries (seed consistency + four coherence + neg_complete)

For Task 658 scope (just four coherence conditions, assuming neg_complete gets fixed separately): **13-17 hours**

### General Proof Pattern

Each coherence condition proof follows this structure:

```lean
intro t t' phi hlt h_temporal_op
-- hlt: t < t' (or t' < t for backward conditions)
-- h_temporal_op: G/H phi ∈ mcs(t) or mcs(t')

-- Case analysis on time positions
cases' (trichotomous 0 t) with ht0 ht0
case neg => -- t < 0 (past)
  cases' (trichotomous 0 t') with ht'0 ht'0
  case neg => -- t' < 0 (both in past)
    sorry -- handle past-past case
  case zero => -- t' = 0 (past to origin)
    sorry -- handle past-origin case
  case pos => -- t' > 0 (past to future, through origin)
    sorry -- handle past-future case
case zero => -- t = 0 (origin)
  cases' ... -- similar subcases for t'
case pos => -- t > 0 (future)
  cases' ... -- similar subcases for t'
```

### Key Tactics

- **Case analysis**: `cases'`, `split_ifs`, `by_cases`
- **Seed membership**: `simp only [time_seed, future_seed, past_seed]`
- **MCS extension**: `apply mcs_at_time_contains_seed`
- **Axiom usage**: `have h_ax := theorem_in_mcs _ _ (DerivationTree.axiom [] _ (Axiom.temp_4 _))`
- **Transitivity**: `trans` tactic for chaining inequalities
- **Contradiction**: `by_contra`, `absurd`

## Recommendations

### For Implementation Planning

1. **Phase 1: Prerequisites** (6-10 hours)
   - Fix `CanonicalWorld.neg_complete` (4-5 hours)
   - Prove seed consistency lemmas (6-8 hours, but can be done in parallel)
   - Create helper lemmas for case analysis

2. **Phase 2: Direct Coherence** (5-7 hours)
   - Prove forward_G (3-4 hours)
   - Prove backward_H (2-3 hours)

3. **Phase 3: Inverse Coherence** (8-10 hours)
   - Prove backward_G (4-5 hours)
   - Prove forward_H (4-5 hours)

### Alternative Approach: Partial Progress

If full proofs prove too difficult:

1. **Prove forward_G and backward_H only** (5-7 hours)
   - These are more direct from seed construction
   - Leaves forward_H and backward_G as documented sorries
   - Still significant progress on coherence conditions

2. **Document proof obligations clearly**
   - Add detailed comments explaining what's needed
   - Reference specific axioms and lemmas required
   - Provide proof sketches for future work

### Risk Mitigation

**Risk**: Negation completeness blocker
- **Mitigation**: Research alternative proof approaches that don't require neg_complete
- **Fallback**: Document the dependency clearly and create a separate task for neg_complete

**Risk**: Temporal axiom propagation more complex than expected
- **Mitigation**: Use `lean_multi_attempt` to test different tactic combinations
- **Fallback**: Use `lean_state_search` to find relevant Mathlib lemmas for specific goals

**Risk**: Case analysis explosion
- **Mitigation**: Factor out common subproofs as helper lemmas
- **Pattern**: Create `coherence_helper_origin_to_future` style lemmas

## References

### Source Files
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Representation/IndexedMCSFamily.lean` - Main file with four sorries
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Representation/CanonicalWorld.lean` - Helper lemmas
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean` - Temporal axioms
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Derivation.lean` - Proof system

### Documentation
- `specs/reviews/review-20260121-task654.md` - Task 654 review (lines 115-122 mention coherence conditions)
- IndexedMCSFamily.lean docstring (lines 6-42) - Design rationale

### Related Tasks
- Task 654: Universal Parametric Representation Theorem (parent task)
- Seed consistency proofs are medium priority from Task 654 review

## Next Steps

1. **Create implementation plan** using `/plan 658`
   - Use phased approach: prerequisites → direct coherence → inverse coherence
   - Allocate 8-12 hours total (as per TODO.md)

2. **Decide on neg_complete dependency**
   - Either: include fixing neg_complete in this task (adds 4-5 hours)
   - Or: create separate task for neg_complete, mark as dependency

3. **Set up verification strategy**
   - Use `lean_goal` frequently to check proof state
   - Use `lean_diagnostic_messages` after each case
   - Use `lean_multi_attempt` for tactic exploration

4. **Research Mathlib lemmas for**
   - Ordered additive group transitivity: `Lt.trans` or similar
   - Case analysis on trichotomy: search for trichotomous lemmas
   - Temporal operator properties in existing proofs

## Appendix: Coherence Semantic Meaning

Understanding WHY these conditions are needed:

**forward_G**: If G phi is true at t (phi holds at all future times from t's perspective), and t' is in the future of t, then phi must hold at t'. This is direct temporal propagation.

**backward_H**: Dual to forward_G for past direction.

**forward_H**: If at future time t' we assert "phi held at all past times" (H phi), then in particular phi must have held at earlier time t (since t < t' means t is in t's past). This is consistency of past claims.

**backward_G**: If at past time t' we assert "phi will hold at all future times" (G phi), then in particular phi must hold at later time t (since t' < t means t is in t's future). This is consistency of future predictions.

The last two are subtle: they ensure that temporal claims made at different times are COHERENT - you can't claim "it was always true" at time t' without it actually having been true at earlier times t.
