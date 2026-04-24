# Phase 1 v7 Handoff: Binary g Rebuild Analysis

## What Was Accomplished

### Phase 0: ROADMAP Update [COMPLETED]
- Updated ROADMAP.md with chronicle as primary completeness path
- Added binary g finding, density axiom finding, dead end #37
- Updated sorry inventory, priority order, cross-reference table

### Phase 1: Partial Progress

#### New Sorry-Free Lemmas (PointInsertion.lean)
1. **`G_implies_F_mcs`**: G(alpha) in MCS implies F(alpha) in MCS
   - Uses seriality + BX3 (right_mono_until) + BX10 + BX12
   - Chain: G(a) -> G(T->a) -> (TUT from seriality+BX12) -> (TUa by BX3) -> F(a) by BX10
   - This is a KEY new result not previously known in this codebase

2. **`H_implies_P_mcs`**: Mirror for past direction

3. **`g_propagation_seed_consistent`**: {alpha} union g_content(A) is consistent when G(alpha) in A
   - Follows from G_implies_F_mcs + forward_temporal_witness_seed_consistent

4. **`g_propagation_witness`**: Given G(alpha) in MCS A, produces MCS D with alpha in D and g_content(A) subset D

#### New Infrastructure (CounterexampleElimination.lean)
5. Added `g_prop_forward` and `g_prop_backward` to PotentialCounterexampleKind
6. **`eliminate_g_prop_counterexample`**: Inserts point between adjacent x,y when G(alpha) in f(x), alpha not in f(y)
7. **`eliminate_h_prop_counterexample`**: Mirror for H-propagation

All code compiles sorry-free. Full `lake build` passes.

## Critical Analysis: Why g_content_chain_property Remains Open

### The Fundamental Obstacle

The g_content_chain_property (for all x < y in limit_dom, g_content(limit_f(x)) subset limit_f(y)) cannot be proved with ANY of the following approaches:

#### Approach 1: G-propagation counterexample elimination (implemented above)
- Inserts points between adjacent pairs where G-propagation fails
- PROBLEM: This only breaks adjacency but does NOT put alpha into f(y)
- Since f(y) is never modified after insertion, if alpha not in f(y), it stays out
- Infinitely many points accumulate approaching y from below, all with G(alpha), but alpha never enters f(y)
- STATUS: Infrastructure is correct and useful, but insufficient alone

#### Approach 2: Enlarge C5 seed to {eta} union g_content(f(max_dom))
- Would maintain chain property if seed is consistent
- PROBLEM: Seed consistency requires F(eta) in f(max_dom)
- F(eta) is in f(triggering_point) but does NOT propagate through g_content
- F is existential, G is universal -- g_content only carries G-formulas
- If G(neg eta) in f(max_dom), the seed IS inconsistent (no contradiction derivable)
- STATUS: BLOCKED by F-propagation gap

#### Approach 3: Place C5 witness immediately after triggering point
- Chain property holds for (triggering_point, new_point) by seed design
- PROBLEM: Chain property fails for (new_point, successor)
- g_content(f(new_point)) is unconstrained by Lindenbaum opacity
- The successor's f was fixed before the new point was created
- STATUS: Same fundamental issue as Approach 1

#### Approach 4: Binary g(x,y) maintained through the chain
- Plan v7's proposed approach
- g(x,y) subset f(y) would give the chain property
- PROBLEM: Defining g(x,y) subset f(y) IS the chain property for adjacent pairs
- Binary g reformulates the problem but does not solve it
- The obstacle is always: ensuring Lindenbaum extensions include the right G-formulas
- STATUS: Reformulation, not resolution

### Root Cause

The irreducible mathematical obstacle is:

1. f(y) is determined at insertion time and never changed afterward
2. Lindenbaum extensions (used for insertion) are opaque -- we cannot control what extra formulas they add
3. The seed for f(y) contains g_content of the triggering point only
4. For x != triggering_point, g_content(f(x)) is NOT guaranteed to be in f(y)
5. F-formulas do not propagate through g_content (F is existential, g_content is universal)

This is the SAME Lindenbaum opacity that blocks the BXCanonical path (dead ends #34-#36), manifesting in the chronicle construction.

### Possible Resolutions (Not Yet Attempted)

1. **Two-phase construction**: Build the omega-chain in two phases:
   - Phase A: Insert all C5/C5' witnesses (as currently done)
   - Phase B: For each inserted point y, extend f(y) to include g_content from predecessors using a SECOND omega-chain. This requires f(y) to be REDEFINABLE, which contradicts f-agreement.

2. **Burgess's actual construction**: In Burgess 1982, the chronicle conditions are maintained at EVERY finite stage, not just in the limit. This means the construction is more careful about what goes into each inserted MCS. The exact mechanism for maintaining g_content propagation needs careful extraction from the paper. The codebase's lemma_2_4 may be applying Burgess incorrectly.

3. **Ordinal-indexed construction**: Instead of omega-chain, use a transfinite construction indexed by ordinals. At limit stages, reconstruct f at all points to satisfy g_content propagation. This avoids the f-agreement constraint.

4. **Axiom strengthening**: Add G(alpha) -> alpha (BX1/reflexivity) to make g_content propagation trivial. But this changes the logic from irreflexive to reflexive.

5. **Deterministic construction**: Use a deterministic (non-Lindenbaum) construction where f(y) is fully controlled. The existing DeterministicFMCS.lean has bot-Until linking but is constant under reflexive semantics. Under irreflexive semantics, it might work differently.

## Files Modified

- `/home/benjamin/Projects/ProofChecker/specs/ROADMAP.md` (Phase 0)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (4 new lemmas)
- `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (G-propagation infrastructure)
- `/home/benjamin/Projects/ProofChecker/specs/107_chain_design_diagnostics_for_representation_theorem/plans/17_implementation-plan.md` (status markers)

## Current Sorry Count

Still 12 sorry sites (unchanged from start):
- 1 in ChronicleConstruction.lean (g_content_chain_property -- the critical one)
- 2 in CounterexampleElimination.lean (C4 sub-cases)
- 9 in ChronicleToCountermodel.lean (countermodel wiring)

## Recommendation

The next attempt should focus on Resolution 2: carefully extracting Burgess's actual construction mechanism for maintaining g_content propagation at each finite stage. The existing codebase's lemma_2_4 produces witnesses with g_content of the triggering point, but Burgess may use a different seed or a different insertion strategy that ensures propagation from all predecessors.

The G_implies_F_mcs lemma (G(alpha) -> F(alpha)) is a valuable new tool that was not previously available. It enables seed consistency proofs whenever G(alpha) is available, which is a strictly stronger result than the existing F-based seed consistency.
