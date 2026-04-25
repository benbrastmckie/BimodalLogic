# Implementation Plan: Task #107 (v12 -- Remove Adjacent Restriction, Implement Lemma 2.9)

- **Task**: 107 - Fix C4 Adjacent restriction and implement Lemma 2.9 for non-adjacent C4 elimination
- **Status**: [NOT STARTED]
- **Effort**: 28 hours
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/26_team-research.md]
- **Artifacts**: plans/26_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The codebase has a second C4 definition error: `Adjacent χ.dom x y` restricts C4 to adjacent pairs, but Burgess C4a applies to ALL pairs `x < y`. At the dense limit there are no adjacent pairs, making adjacent C4 vacuously true and forward_G unprovable. The fix removes the `Adjacent` restriction from C4/C4' definitions, generalizes the counterexample elimination to handle non-adjacent pairs via Burgess's Lemma 2.9 induction on intermediate domain points, implements the full Lemma 2.6 seed for the hard case, and closes all 13 remaining sorry sites. Definition of done: sorry-free dd_countermodel_chronicle with clean `#print axioms`.

### Research Integration

Report 26 (team research, 4 teammates, unanimous): The `Adjacent` restriction on C4 is the second definition error (after the argument swap fixed in v11 Phase 1). Burgess C4a says `x < y`, not "adjacent." Lemma 2.9 handles non-adjacent C4 by induction: n=0 is Lemma 2.6 (adjacent, already partially implemented), n=m+1 reduces to adjacent via formula manipulation using A3a (BX4/connect_future in codebase). The omega chain must enumerate ALL-pairs C4 counterexamples, not just adjacent ones.

### Prior Plan Reference

Plan v11 (artifact 25): Phase 1 (C4 argument swap, g_ordered deletion) completed successfully. Phases 2-6 remain NOT STARTED or BLOCKED. The v11 plan's Phase 3 was marked BLOCKED because it assumed adjacent C4 would suffice at the limit -- this assumption is now known to be wrong. Effort calibration from v11: C4 hard case complexity was underestimated; the Lemma 2.6 full seed is substantial. The v11 contingency that "density makes C4 vacuous for adjacent pairs" was identified as the root fallacy -- vacuously true C4 provides zero information.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP Section 2)
- Closing all 13 sorry sites achieves the chronicle sorry-free milestone

## Goals & Non-Goals

**Goals**:
- Remove `Adjacent` restriction from C4/C4' definitions (use `x < y` / `y < x`)
- Remove `Adjacent` from C4Counterexample/C4'Counterexample structures
- Remove adjacency check from omega chain counterexample enumeration
- Implement Lemma 2.9 induction for non-adjacent C4 elimination (n > 0 case)
- Implement Lemma 2.6 full seed (n = 0 base case, currently sorry'd)
- Prove forward_G/backward_H from generalized C4 + C0 at the limit
- Close all 8 ChronicleToCountermodel sorry sites
- Achieve sorry-free dd_countermodel_chronicle
- Maintain lake build at each phase boundary

**Non-Goals**:
- General completeness for all strict linear orders (separate task)
- Fixing sorry sites outside Chronicle/ directory (task 109 scope)
- Cantor isomorphism for non-domain extension (not needed: generalized C4 at limit + C0 gives forward_G directly)
- Two-sided seeds / g_ordered reintroduction (superseded by Lemma 2.9 approach)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lemma 2.9 induction (n > 0) is hard to formalize in Lean | H | M | The induction is on a natural number (count of intermediate domain points). Use `Finset.card` of `{z in dom | x < z /\ z < y}`. Each step reduces the count by at least 1. |
| Lemma 2.6 full seed consistency is complex | H | M | dcs_neg_union_consistent already proves `{neg delta} union B` consistent. The richer seed adds formulas derivable from B's R3Maximality. Paper-proof first, then formalize. |
| A3a axiom (connect_future/BX4) invocation in Lemma 2.9 n>0 case | M | M | A3a is `U(gamma, delta) -> delta \/ (gamma /\ X(U(gamma, delta)))`. The codebase has `connect_future` for this. Verify the exact statement matches Burgess's usage. |
| Omega chain enumeration of ALL pairs produces infinite counterexamples | M | L | At any finite stage, dom is finite, so pairs are finite. The enumeration `potential_counterexamples` already iterates over dom x dom x formulas x formulas. Just remove the `Adjacent` filter. |
| Downstream ChronicleToCountermodel wiring has 8 sorry sites | M | L | Once forward_G/backward_H work, these are mechanical: delegate to limit properties. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Remove Adjacent Restriction from C4/C4' [NOT STARTED]

**Goal**: Change C4/C4' definitions from `Adjacent χ.dom x y` to `x ∈ χ.dom -> y ∈ χ.dom -> x < y`, matching Burgess 1982. Update all dependent structures and the omega chain enumeration.

**Tasks**:
- [ ] Change `Chronicle.c4` definition: replace `Adjacent χ.dom x y ->` with `x ∈ χ.dom -> y ∈ χ.dom -> x < y ->`
- [ ] Change `Chronicle.c4'` definition: replace `Adjacent χ.dom y x ->` with `y ∈ χ.dom -> x ∈ χ.dom -> y < x ->`
- [ ] Update C4/C4' docstrings to say "all pairs x < y" instead of "adjacent"
- [ ] Remove `adj : Adjacent χ.dom x y` from `C4Counterexample` structure; replace with `hxy : x < y`
- [ ] Remove `adj : Adjacent χ.dom y x` from `C4'Counterexample` structure; replace with `hyx : y < x`
- [ ] Update `eliminate_C4_counterexample`: the midpoint insertion now requires a new strategy for non-adjacent pairs (add sorry placeholder for the general case, keep existing adjacent logic as a sub-case)
- [ ] Remove adjacency check from `eliminate_potential_counterexample` (lines 646-650): change `Adjacent χ.dom pc.x pc.y` to `pc.x < pc.y` (for C4) and similarly for C4'
- [ ] Remove adjacency checks from all other `eliminate_potential_counterexample` cases (c4_backward, c3_forward, c3_backward at lines 674, 702, 726, 750)
- [ ] Update `singleton_invariant` C4/C4' obligations (singleton domain has no x < y pairs, so vacuously true)
- [ ] Fix all downstream compilation errors
- [ ] Run lake build and verify

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Chronicle/ChronicleTypes.lean` -- C4/C4' definitions (lines 306-324), C2' adjacency (if needed)
- `Chronicle/CounterexampleElimination.lean` -- C4Counterexample/C4'Counterexample structures, eliminate_potential_counterexample
- `Chronicle/ChronicleConstruction.lean` -- singleton_invariant C4/C4' fields

**Verification**:
- lake build succeeds
- C4 definition uses `x ∈ χ.dom -> y ∈ χ.dom -> x < y`, no `Adjacent`
- C4Counterexample has `hxy : x < y`, no `adj`
- Omega chain enumeration checks `pc.x < pc.y`, no `Adjacent`
- Sorry count may temporarily increase (new sorry in generalized eliminate_C4)

---

### Phase 2: Implement Lemma 2.6 Full Seed (C4 Base Case) [NOT STARTED]

**Goal**: Close the sorry in `lemma_2_6_full` (PointInsertion.lean:762). This is the base case of Lemma 2.9 (adjacent/n=0). The full seed construction creates an MCS D with the negated GUARD using a richer seed than `{neg gamma} union B`.

**Tasks**:
- [ ] Paper-proof the full Lemma 2.6 seed construction:
  - Seed D0 = {neg gamma} union B union {S(alpha, beta) | specific formulas} union {U(gamma_f, beta) | specific formulas}
  - Consistency: if D0 were inconsistent, derive a contradiction with B's R3Maximality
- [ ] Implement lemma_2_6_full: construct the seed set D0
- [ ] Prove consistency of D0 using `dcs_neg_union_consistent` as starting point and R3Maximality of B
- [ ] Apply Lindenbaum extension to get MCS D from D0
- [ ] Prove R3Maximal(D, B', B'') for the required interval relations
- [ ] Close the sorry at PointInsertion.lean:762
- [ ] Close the C4 hard case sorry at CounterexampleElimination.lean:280 (uses lemma_2_6_full)
- [ ] Close the C4' hard case sorry at CounterexampleElimination.lean:350 (mirror)
- [ ] Run lake build and verify

**Timing**: 6 hours

**Depends on**: Phase 1 (C4/C4' definition change determines what the hard case needs)

**Files to modify**:
- `Chronicle/PointInsertion.lean` -- lemma_2_6_full implementation
- `Chronicle/CounterexampleElimination.lean` -- C4/C4' hard case (lines 280, 350)

**Verification**:
- lake build succeeds
- lemma_2_6_full sorry-free
- eliminate_C4_counterexample sorry-free for the adjacent (n=0) sub-case
- eliminate_C4'_counterexample sorry-free for the adjacent sub-case
- Sorry count reduction: -3 (lemma_2_6_full, C4 hard, C4' hard)

---

### Phase 3: Implement Lemma 2.9 Non-Adjacent Induction (n > 0 Case) [NOT STARTED]

**Goal**: Implement the induction on intermediate domain points for non-adjacent C4 elimination. Given a counterexample (x, y, gamma, delta) with n > 0 intermediate domain points between x and y, reduce to a sub-problem with fewer intermediate points.

**Tasks**:
- [ ] Define `intermediate_count` helper: `(χ.dom.filter (fun z => x < z ∧ z < y)).card`
- [ ] Implement `eliminate_C4_counterexample_general` by strong induction on `intermediate_count`:
  - Base case (n = 0, adjacent): delegate to existing `eliminate_C4_counterexample` (now the adjacent sub-case from Phase 2)
  - Inductive case (n = m + 1): find x' = immediate successor of x in dom (min of `{z in dom | x < z ∧ z < y}`)
  - Sub-case A: `neg(untl gamma delta) ∈ f(x')` -- reduce to (x', y) with m intermediate points, apply IH
  - Sub-case B: `untl(gamma, delta) ∈ f(x')` -- then delta ∈ f(x') (by A3a decomposition). Set gamma' = delta ∧ untl(gamma, delta). By A3a: neg(untl(gamma', delta)) ∈ f(x). Reduce to (x, x') with 0 intermediate points.
- [ ] Prove the formula manipulation in Sub-case B using connect_future (BX4/A3a axiom)
- [ ] Mirror for `eliminate_C4'_counterexample_general` (Since direction)
- [ ] Update `eliminate_potential_counterexample` to use the generalized versions
- [ ] Verify the omega chain now eliminates ALL C4 counterexamples (not just adjacent)
- [ ] Run lake build and verify

**Timing**: 8 hours

**Depends on**: Phase 1 (generalized C4 definition), Phase 2 is a Wave-2 peer but the general elimination calls the adjacent base case from Phase 2

**Files to modify**:
- `Chronicle/CounterexampleElimination.lean` -- new `eliminate_C4_counterexample_general`, update `eliminate_potential_counterexample`
- `Chronicle/ChronicleTypes.lean` -- possible helper definitions for intermediate_count

**Verification**:
- lake build succeeds
- `eliminate_C4_counterexample_general` handles arbitrary n (sorry-free)
- Omega chain processes C4 counterexamples for ALL pairs x < y
- All C4/C4' sorry sites in CounterexampleElimination.lean closed

---

### Phase 4: Prove forward_G/backward_H from Generalized C4 + C0 [NOT STARTED]

**Goal**: With the omega chain now eliminating ALL C4 counterexamples, prove that at the limit every C4 condition is satisfied for ALL pairs. Then prove forward_G via the C4 + C0 contradiction argument.

**Tasks**:
- [ ] Prove `limit_c4_generalized`: for any x < y in limit_dom, if neg(untl(gamma, delta)) in limit_f(x) and delta in limit_f(y), then exists z in limit_dom with gamma.neg in limit_f(z) and x < z < y.
  - Proof sketch: x and y enter dom at some finite stage. The counterexample (x, y, gamma, delta) is enumerated and eliminated at some stage N. By f-immutability and dom-monotonicity, the witness z persists to the limit.
- [ ] Prove `limit_c4'_generalized` (mirror for Since)
- [ ] Prove `limit_forward_G` (close sorry at ChronicleConstruction.lean:853):
  - G(phi) = neg(untl(top, phi.neg)) in f(x)
  - Suppose phi.neg in f(y) for some y > x -- phi.neg is the EVENT
  - By limit_c4_generalized: exists z with top.neg = bot in f(z)
  - bot in MCS contradicts C0
- [ ] Prove `limit_backward_H` (close sorry at ChronicleConstruction.lean:870, mirror)
- [ ] Run lake build and verify

**Timing**: 4 hours

**Depends on**: Phase 2 (adjacent elimination sorry-free), Phase 3 (non-adjacent elimination sorry-free, omega chain covers all pairs)

**Files to modify**:
- `Chronicle/ChronicleConstruction.lean` -- limit_c4_generalized, limit_forward_G, limit_backward_H

**Verification**:
- lake build succeeds
- limit_forward_G sorry-free
- limit_backward_H sorry-free
- Sorry count reduction: -2

---

### Phase 5: Close ChronicleToCountermodel Sorry Sites [NOT STARTED]

**Goal**: Close all 8 remaining sorry sites in ChronicleToCountermodel.lean. With forward_G/backward_H proved and C5/C5' established, these are mechanical wiring to limit chronicle properties.

**Tasks**:
- [ ] Close chronicle_fmcs forward_G sorry (line 195): delegate to limit_forward_G
- [ ] Close chronicle_fmcs backward_H sorry (line 200): delegate to limit_backward_H
- [ ] Close restricted_tc forward sorry (line 372): F(phi) resolution via limit C5 + density
- [ ] Close restricted_tc backward sorry (line 375): P(phi) resolution via limit C5'
- [ ] Close restricted_buc Until sorry (line 394): backward Until from generalized C4 + C3
- [ ] Close restricted_buc Since sorry (line 397): mirror
- [ ] Close restricted_fuc Until sorry (line 426): forward Until from C5 + C3 guard transfer
- [ ] Close restricted_fuc Since sorry (line 429): mirror
- [ ] Verify dd_countermodel_chronicle compiles sorry-free
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify no sorryAx

**Timing**: 6 hours

**Depends on**: Phase 4 (forward_G/backward_H sorry-free)

**Files to modify**:
- `Chronicle/ChronicleToCountermodel.lean` -- close all 8 sorry sites

**Verification**:
- lake build succeeds
- ChronicleToCountermodel.lean sorry-free
- dd_countermodel_chronicle sorry-free
- `#print axioms dd_countermodel_chronicle` shows only Lean axioms (propfunext, Quot.sound, Classical.choice)
- Sorry count: 0 in Chronicle/

---

### Phase 6: Cleanup and Validation [NOT STARTED]

**Goal**: Final cleanup. Remove dead code, verify no regressions, update documentation.

**Tasks**:
- [ ] Remove `Adjacent` from C4-related comments and dead docstrings throughout Chronicle/
- [ ] Clean up any remaining g_ordered references in comments
- [ ] Remove unused helper functions from the old adjacent-only approach
- [ ] Verify no regressions: full lake build, check sorry count across entire project
- [ ] Verify axiom audit: `#print axioms dd_countermodel_chronicle`
- [ ] Ensure Soundness, FMP, ParametricTruthLemma remain sorry-free

**Timing**: 2 hours

**Depends on**: Phase 5 (sorry-free dd_countermodel_chronicle)

**Files to modify**:
- `Chronicle/*.lean` -- dead code removal, docstring cleanup

**Verification**:
- lake build succeeds (full clean build)
- Zero sorry sites in Chronicle/ directory
- No regressions in other modules

## Testing & Validation

- [ ] lake build succeeds at each phase boundary (6 checkpoints)
- [ ] Phase 1: C4/C4' definitions use `x < y` with no `Adjacent`; omega chain enumerates all pairs
- [ ] Phase 2: lemma_2_6_full sorry-free; C4/C4' hard cases sorry-free
- [ ] Phase 3: Lemma 2.9 non-adjacent induction sorry-free; omega chain eliminates all C4 counterexamples
- [ ] Phase 4: limit_forward_G/backward_H sorry-free from generalized C4 + C0
- [ ] Phase 5: ChronicleToCountermodel.lean sorry-free; dd_countermodel_chronicle sorry-free
- [ ] Phase 6: Full clean build; zero sorry in Chronicle/; `#print axioms` clean
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] Each paper-proof step validated before Lean formalization

## Artifacts & Outputs

- `specs/107_.../plans/26_implementation-plan.md` (this file)
- Modified: `Chronicle/ChronicleTypes.lean` (C4/C4' generalization, remove Adjacent)
- Modified: `Chronicle/CounterexampleElimination.lean` (Lemma 2.9 general, structures, omega chain)
- Modified: `Chronicle/PointInsertion.lean` (lemma_2_6_full implementation)
- Modified: `Chronicle/ChronicleConstruction.lean` (limit_c4_generalized, forward_G, backward_H)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (close all 8 sorry sites)

## Rollback/Contingency

- **Git safety**: The irr_until branch preserves the current state. All changes can be reverted to HEAD.
- **Phase 1 contingency**: The Adjacent removal is a definition change. If it causes more breakage than expected, revert and keep Adjacent in the definition while adding a separate `c4_general` predicate proved from density + adjacent C4.
- **Phase 2 contingency**: If lemma_2_6_full is intractable, the easy cases of C4 elimination (neg gamma already in f(x) or f(y)) still work. Leave the hard case sorry'd and proceed to Phase 3/4 -- forward_G can still be proved if the omega chain ensures no hard-case counterexamples survive to the limit.
- **Phase 3 contingency**: If the Lean induction on intermediate_count is difficult, try `Finset.strongRecOn` or `WellFoundedRelation` on `Nat.lt`. The mathematical argument is straightforward; the formalization challenge is in managing the Finset operations.
- **Phase 4 contingency**: If the omega-chain-to-limit transfer is hard, split into two lemmas: (a) every counterexample is eliminated at some finite stage, (b) elimination witnesses persist to the limit. Both use standard omega chain properties (f-immutability, dom-monotonicity).
- **Phase 5 contingency**: If non-domain extension creates issues for ChronicleToCountermodel, apply the Cantor isomorphism fallback (Order.iso_of_countable_dense from Mathlib).
- **Budget overrun**: Phases 1+4 alone (generalized C4 + forward_G) remove the structural blocker. Phases 2+3 can be interleaved. Phase 5 is downstream wiring.
