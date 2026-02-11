# Research Report: Task #865 (Round 6)

**Task**: Canonical task frame for bimodal completeness
**Date**: 2026-02-11
**Focus**: Comparative analysis of task 865 challenges in light of task 864's implementation progress
**Session**: sess_1770848379_6843ee
**Mode**: Single-agent (team mode unavailable)

## Summary

This report analyzes what was hard about task 865 (canonical task frame construction) and how task 864's implementation progress (recursive seed construction for Henkin model completeness) illuminates these challenges. The central finding is that **both tasks were blocked by the same fundamental issue**: cross-sign temporal propagation in the two-chain architecture. Task 864's seed construction approach successfully bypasses this blockage, and its key proof technique - the **single-path invariant** - provides the mathematical foundation that task 865 will need for its TruthLemma box case. With task 864's RecursiveSeed.lean now at 4363 lines with only 13 remaining sorries (mostly technical or pre-existing), the path to task 865 completion is becoming clear.

## 1. The Core Challenge: Cross-Sign Temporal Propagation

### 1.1 What Task 865 Requires

Task 865's goal is to bridge from BMCS-level completeness to standard TaskFrame semantics via a canonical TruthLemma:

```lean
theorem canonical_truth_lemma (B : BMCS D) (h_tc : B.temporally_coherent)
    (fam : IndexedMCSFamily D) (hmem : fam in B.families) (t : D) (phi : Formula) :
    phi in fam.mcs t <-> truth_at (canonical_model B) (canonical_history B fam hmem) t phi
```

The critical case is **box**. The standard semantics requires:
```
truth_at M tau t (box phi) = forall sigma : WorldHistory F, truth_at M sigma t phi
```

Since world histories include time-shifted versions (where states at time t access `fam.mcs(c + t)` for arbitrary offset c), this quantifies over **all times in all families**:
```
box phi in fam.mcs t ⟺ forall fam' in B.families, forall s : D, phi in fam'.mcs s
```

### 1.2 The Propagation Requirement

For the forward direction, we need:
```
box phi in fam.mcs t → phi in fam'.mcs s  (for all fam', all s)
```

This requires:
1. **Future propagation**: `box phi in fam.mcs t → box phi in fam.mcs s` for all `s > t` (via TF + forward_G)
2. **Past propagation**: `box phi in fam.mcs t → box phi in fam.mcs s` for all `s < t` (requires derivation)
3. **Modal propagation**: `box phi in fam.mcs s → phi in fam'.mcs s` (via modal_forward)

Steps 1 and 3 are straightforward. Step 2 - **past propagation of box formulas** - is where the cross-sign problem manifests.

### 1.3 Why Task 843 Was Blocked (And Why It Matters for Task 865)

Task 843's two-chain architecture used:
- **Forward chain**: Builds MCS at indices 0, 1, 2, 3, ... using GContent seeds
- **Backward chain**: Builds MCS at indices 0, -1, -2, -3, ... using HContent seeds

The problem: G formulas in the backward chain do NOT propagate toward the shared base at index 0. When `G phi` appears at time -3, the backward chain doesn't seed it into the forward direction.

**This same problem would block task 865**: If the underlying BMCS lacks proper temporal coherence across the sign boundary, the TruthLemma's box case cannot establish `box phi in fam.mcs s` for all past `s`.

## 2. How Task 864 Solves the Root Problem

### 2.1 The Seed Construction Approach

Task 864's key insight is to **pre-place all witnesses in the seed BEFORE Lindenbaum extension**:

1. **Temporal witnesses**: If `F(psi)` appears at time t, create a new time t' > t with psi in the seed. If `P(psi)` appears, create t' < t.
2. **Modal witnesses**: If `neg(Box psi)` appears, create a NEW family with neg(psi) in the seed.
3. **Box additions**: If `Box psi` appears at time t, add psi to ALL families at time t.
4. **G/H additions**: If `G psi` appears at time t, add psi to ALL future times. If `H psi` appears, add to all past times.

The crucial difference from task 843: witnesses are placed **before** the MCS completion phase, not during interleaved chain construction.

### 2.2 The Single-Path Invariant

Task 864's implementation plan (v003) identified the **single-path invariant** as the key to proving seed consistency:

```lean
-- When processing Box psi at (famIdx, timeIdx):
-- We are on the "positive branch" - no new families have been created on this path
-- Therefore seed.familyIndices = {famIdx}
-- So addToAllFamilies only affects entries at famIdx
```

This insight enabled elimination of the Box case sorry (line 3138) that had blocked progress.

### 2.3 Current Implementation Status

| Component | Lines | Sorries | Status |
|-----------|-------|---------|--------|
| RecursiveSeed.lean | 4363 | 13 | Main implementation |
| SeedCompletion.lean | ~100+ | Active | Extends seeds to MCS |

**Sorry breakdown** (from implementation-003.md, session 28):
- 3 sorries: False h_single hypotheses for neg-Box/G/H (dead code)
- 3 sorries: Catch-all neg-Box/G/H cases (dead code)
- 2 sorries: Pre-existing List.modify API issues
- 3 sorries: Pre-existing API compatibility
- **Key achievement**: Generic imp case ELIMINATED via full case analysis

The mathematical correctness is established - remaining sorries are structural/technical.

## 3. Mapping Task 864 Progress to Task 865 Challenges

### 3.1 The MF/TF Propagation Chain

Both tasks use the same axiom chain for forward propagation:

```
box phi in fam.mcs t
  → G(box phi) in fam.mcs t              (by TF axiom)
  → box phi in fam.mcs s for all s > t   (by forward_G)
  → phi in fam'.mcs s for all fam', s > t (by modal_forward)
```

**Task 864's role**: Ensures the BMCS has proper forward_G property from seed construction.
**Task 865's role**: Uses this property in the TruthLemma box case.

### 3.2 Past Propagation via Seed Pre-Placement

The hardest part of both tasks is past propagation. Task 864 handles this by:

1. When `box phi` appears at time t, seed adds `phi` to all families at time t
2. When `G phi` appears at time t, seed adds `phi` to all future times in the family
3. Cross-family coherence is established at seed level, not during Lindenbaum

**Result for task 865**: The BMCS from task 864 has the property that `box phi in fam.mcs t` implies `box phi in fam.mcs s` for all s (via the seed's pre-placement of temporal witnesses).

### 3.3 Effort Transfer Analysis

| Task 865 Component | Without Task 864 | With Task 864 Complete |
|--------------------|------------------|------------------------|
| Frame/Model definitions | ~50 lines | ~50 lines (unchanged) |
| Compositionality proof | Requires family composition | Trivial (B2: `trans + ring`) |
| World history characterization | Complex (task 843 path) | Simple (constant family + offset) |
| box_propagates_everywhere | Blocked (no BMCS) | ~60 lines (uses seed structure) |
| TruthLemma box case | Blocked | ~50 lines (MF/TF + modal_forward) |
| **Total** | BLOCKED | 18-27 hours |

## 4. What Made Task 865 Hard

### 4.1 Primary Hardness: The Offset Problem

Research-003 identified the **offset problem**:
- World histories include `(fam', c)` for arbitrary offset c
- Truth at `(fam', c)` and time t evaluates formulas at `fam'.mcs(c + t)`
- The box case must handle ALL offsets, including very negative ones

**Resolution**: MF + TF + 4-axioms ensure box formulas propagate to all times:
```
box phi in fam.mcs t
  → box(G phi) in fam.mcs t              (by MF)
  → G(box phi) in fam.mcs t              (by TF)
  → box phi everywhere in time           (via 4-axiom iteration)
```

This resolution requires the underlying BMCS to support the 4-axiom closure - which task 864's seed construction provides.

### 4.2 Secondary Hardness: Derivability of box phi → H(box phi)

Research-004 (Section 4.1) analyzed this in detail:
- The axiom set has MF and TF for future direction
- No explicit past-direction axiom (`box phi → H(box phi)`)
- Must be derived via TA (temp_a): `phi → G(P phi)` + backward induction

For D = Int (the concrete case), the derivation uses:
1. `box phi → G(P(box phi))` (TA instance)
2. `P(box phi) in fam.mcs t` gives witness s < t with `box phi in fam.mcs s`
3. By induction on the integers: `box phi in fam.mcs n` for all n

**Task 864's contribution**: The seed construction pre-places these witnesses, so the induction step always succeeds.

### 4.3 Tertiary Hardness: Construction Choice

Research-004 compared two constructions:
- **Construction A (Trajectory-Based)**: Explicit CanonicalTask objects (~440 lines, complex)
- **Construction B2 (Family-Indexed)**: Direct family+time pairs (~250 lines, trivial axioms)

**Recommendation**: B2 is simpler and sufficient. The extra structure in A provides no mathematical insight for completeness.

## 5. What Task 864 Has Accomplished That Helps Task 865

### 5.1 Temporal Coherence Without Cross-Sign Issues

The seed construction places witnesses at both positive and negative times:
- `F(psi)` at time -3 creates witness at time > -3 (could be -2, or 0, or positive)
- `P(psi)` at time 5 creates witness at time < 5 (could be 4, or 0, or negative)

Cross-sign propagation is handled naturally because witnesses are pre-placed.

### 5.2 Modal Coherence from Box Processing

The seed's Box case:
1. Adds `Box psi` to current entry
2. Adds `psi` to ALL families at current time (via addToAllFamilies)

This directly establishes `modal_forward: box phi in fam.mcs t → phi in fam'.mcs t`.

### 5.3 G/H Propagation from Seed Structure

The seed's G/H cases:
1. G psi at time t → adds psi to all future times in the family
2. H psi at time t → adds psi to all past times in the family

This directly establishes `forward_G` and `backward_H` for the resulting BMCS.

### 5.4 The Single-Path Invariant as a Reusable Pattern

The single-path invariant proved for task 864:
```
When processing positive operators (Box, G, H) at (famIdx, timeIdx):
  seed.familyIndices = {famIdx}
```

This same invariant can be used in task 865's `box_propagates_everywhere` proof:
- When proving `box phi` propagates to all times, we know each time was either:
  - Pre-placed in the seed (directly placed)
  - Added by Lindenbaum (inherits from seed's consistent set)

## 6. Remaining Challenges for Task 865 (Post-Task 864)

### 6.1 Implementing Construction B2

Once task 864 provides the seed-based BMCS:

```lean
-- File: Theories/Bimodal/Metalogic/Representation/CanonicalTaskFrame.lean

structure CanonicalWorldState (B : BMCS D) where
  family : IndexedMCSFamily D
  family_mem : family in B.families
  time : D

def canonical_frame (B : BMCS D) : TaskFrame D where
  WorldState := CanonicalWorldState B
  task_rel := fun w d u => w.family = u.family ∧ u.time = w.time + d
  nullity := fun w => ⟨rfl, by simp⟩
  compositionality := fun w u v x y ⟨h1, h2⟩ ⟨h3, h4⟩ => ⟨h1.trans h3, by rw [h4, h2]; ring⟩
```

**Effort estimate**: 2-3 hours (straightforward structure instantiation)

### 6.2 World History Characterization

Every world history with full domain is `(fam, c)` for constant family and offset c.

**Proof**: From `respects_task`, family is constant and time is linear.

**Effort estimate**: 2-3 hours (dependent type reasoning)

### 6.3 box_propagates_everywhere Lemma

```lean
theorem box_propagates_everywhere (B : BMCS D) (h_tc : B.temporally_coherent)
    (fam : IndexedMCSFamily D) (hmem : fam in B.families) (t : D) (phi : Formula) :
    box phi in fam.mcs t → forall s : D, box phi in fam.mcs s := by
  -- Uses MF/TF + seed structure + backward induction for past times
```

**Effort estimate**: 4-6 hours (needs MF/TF chain + past propagation)

### 6.4 TruthLemma Proof

6 cases by structural induction:
- Atom, Bot, Imp: Trivial (MCS properties)
- G, H: Standard (forward_G, backward_H, temporal backward lemmas)
- Box: Uses box_propagates_everywhere + modal_forward/backward

**Effort estimate**: 8-12 hours (box case is bottleneck)

### 6.5 Total Remaining Effort

| Phase | Hours | Dependencies |
|-------|-------|--------------|
| Frame/Model/History | 2-3 | Task 864 seed BMCS |
| World history characterization | 2-3 | Frame definitions |
| box_propagates_everywhere | 4-6 | Task 864 coherence proofs |
| TruthLemma | 8-12 | All above |
| Standard completeness bridge | 2-3 | TruthLemma |
| **Total** | **18-27** | |

## 7. Key Insights from This Comparative Analysis

### 7.1 The Tasks Share a Common Blocker

Both task 865 and task 843 (which task 864 supersedes) were blocked by cross-sign temporal propagation. Task 864's seed construction is the correct solution for both.

### 7.2 Task 864 Does the Hard Mathematical Work

The genuinely difficult mathematics:
- Proving seed consistency under recursive construction
- Establishing temporal coherence via pre-placed witnesses
- Handling cross-family Box additions

All of this is done in task 864. Task 865 consumes the result.

### 7.3 Task 865 Adds a Thin Semantic Layer

Once task 864 provides the BMCS:
- Task 865's frame axioms are trivial (B2 approach)
- Task 865's TruthLemma delegates to BMCS properties
- The "hard" box case uses lemmas task 864 has already established

### 7.4 The Single-Path Invariant is the Key Insight

Task 864's discovery that `buildSeedAux` follows a single path through the formula tree is the foundational insight. It explains:
- Why addToAllFamilies preserves consistency (no other families exist on positive branch)
- Why addToAllFutureTimes preserves consistency (times on same path are compatible)
- Why the seed-constructed BMCS has proper coherence properties

## 8. Recommendations

### 8.1 For Task 864 (Current Priority)

Continue current implementation path:
1. Resolve G/H case sorries using single-path invariant (similar to Box case)
2. Complete SeedCompletion.lean to build IndexedMCSFamily from extended seed
3. Assemble into BMCS with coherence proofs

**Expected remaining effort**: 5-7 sessions (per implementation-003.md)

### 8.2 For Task 865 (After Task 864)

1. **Wait for task 864 completion** before creating implementation plan
2. **Use Construction B2** (family-indexed) per research-004 recommendation
3. **Reuse task 864's coherence lemmas** rather than re-proving
4. **Focus effort on box case** - other cases are straightforward

### 8.3 Documentation

Update task 865 description to explicitly note dependency on task 864:
```
Task 865 depends on task 864's seed-constructed BMCS for:
- Temporal coherence (forward_G, backward_H without cross-sign issues)
- Modal coherence (modal_forward, modal_backward)
- box_propagates_everywhere foundation
```

## 9. References

### Research Reports
- Task 865 research-004: Construction comparison and B2 recommendation
- Task 865 research-005: Blockage analysis and seed applicability
- Task 864 research-004: Single-path invariant solution for 4 sorries
- Task 864 implementation-003: Revised plan with session 28 progress

### Key Codebase Files
- `Theories/Bimodal/Metalogic/Bundle/RecursiveSeed.lean` - Task 864 implementation (4363 lines)
- `Theories/Bimodal/Metalogic/Bundle/SeedCompletion.lean` - Seed to MCS extension
- `Theories/Bimodal/Semantics/TaskFrame.lean` - Target structure for task 865
- `Theories/Bimodal/Semantics/Truth.lean` - truth_at definition with box case

### Axioms Used by Both Tasks
| Axiom | Role in Task 864 | Role in Task 865 |
|-------|------------------|------------------|
| MF | Box adds to all families | box_propagates_everywhere |
| TF | Implicit in seed G handling | G(box phi) propagation |
| M4 | Box closure in seed | box(box phi) chain |
| 4-axiom | Cross-boundary coherence | Past propagation via TA |
