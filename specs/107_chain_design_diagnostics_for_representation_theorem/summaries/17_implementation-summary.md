# Implementation Summary: Task #107 (v7 -- Binary g Rebuild)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Plan**: plans/17_implementation-plan.md
- **Status**: PARTIAL (Phase 0 completed, Phase 1 partial)
- **Phases**: 1 of 6 completed (Phase 0), 1 partial (Phase 1)

## Completed Work

### Phase 0: Update ROADMAP.md [COMPLETED]
- Updated ROADMAP.md to reflect chronicle as primary completeness path
- Added binary g-function finding (report 17), density axiom finding (report 11)
- Added dead end #37 assessment (chronicle is NOT a dead end)
- Updated sorry inventory (12 chronicle + 19 BXCanonical)
- Updated priority order (task 107 as primary, task 109 as secondary)
- Added task 107 and 112 to cross-reference table
- Commit: b6402c67a

### Phase 1: Rebuild Binary g Function [PARTIAL]

#### New sorry-free lemmas added:

1. **`G_implies_F_mcs`** (PointInsertion.lean): G(alpha) in MCS implies F(alpha) in same MCS.
   Novel derivation using seriality + BX3 + BX10 + BX12. Key chain:
   G(a) -> G(T->a) -> (TUT from seriality+BX12) -> (TUa by BX3) -> F(a) by BX10.

2. **`H_implies_P_mcs`** (PointInsertion.lean): Mirror for past direction.

3. **`g_propagation_seed_consistent`** (PointInsertion.lean): {alpha} union g_content(A) is consistent when G(alpha) in A.

4. **`g_propagation_witness`** (PointInsertion.lean): Constructs MCS with alpha and g_content(A) from G(alpha) in A.

5. **`eliminate_g_prop_counterexample`** (CounterexampleElimination.lean): G-propagation counterexample elimination for adjacent pairs.

6. **`eliminate_h_prop_counterexample`** (CounterexampleElimination.lean): H-propagation counterexample elimination.

7. Extended `PotentialCounterexampleKind` with `g_prop_forward` and `g_prop_backward`.

8. Full integration into `eliminate_potential_counterexample`.

#### Why g_content_chain_property remains open:

Detailed analysis (see handoffs/phase1-v7-handoff.md) identified that:

- G-propagation counterexample elimination breaks adjacency but cannot put alpha into f(y) (f(y) is immutable after insertion)
- Enlarging C5 seed to include g_content(f(max_dom)) fails because F(eta) doesn't propagate through g_content
- Binary g(x,y) reformulates the problem but the same Lindenbaum opacity blocks g(x,y) subset f(y)
- The root cause is that Lindenbaum extensions are opaque and f-values are immutable

## Sorry Count

12 sorry sites (unchanged from start):
- 1 in ChronicleConstruction.lean (g_content_chain_property)
- 2 in CounterexampleElimination.lean (C4 sub-cases 1a)
- 9 in ChronicleToCountermodel.lean (countermodel wiring)

## Build Status

`lake build` passes with no errors. All new code is sorry-free.

## Files Modified

| File | Change |
|------|--------|
| `specs/ROADMAP.md` | Comprehensive update |
| `Chronicle/PointInsertion.lean` | +4 new lemmas (G_implies_F_mcs, etc.) |
| `Chronicle/CounterexampleElimination.lean` | +2 kinds, +2 elimination functions |
| `specs/107_.../plans/17_implementation-plan.md` | Phase status markers |
| `specs/107_.../handoffs/phase1-v7-handoff.md` | Detailed analysis |

## Recommendation

The next attempt should carefully extract Burgess's actual construction mechanism from the 1982 paper. The codebase's current construction (inserting witnesses with g_content of the triggering point) may diverge from Burgess's approach, which maintains g_content propagation at every finite stage. The G_implies_F_mcs lemma provides new capability not previously available.
