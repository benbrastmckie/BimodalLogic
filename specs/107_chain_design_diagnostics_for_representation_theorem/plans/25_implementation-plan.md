# Implementation Plan: Task #107 (v11 -- C4 Definition Fix, Clean Redesign)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 18 hours
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/25_team-research.md]
- **Artifacts**: plans/25_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

The codebase's C4 definition has its arguments swapped relative to Burgess 1982, causing the entire g_ordered blocker and 25 rounds of research. With the correct C4 (check EVENT at f(y), negate GUARD at f(z)), forward_G follows from C4 + C0 in a one-step contradiction: G(phi) = neg(untl(top, phi.neg)), so C4 checks phi.neg (event) at f(y) and produces top.neg = bot at f(z), contradicting C0 (MCS). This means g_ordered is unnecessary and should be deleted. The plan swaps C4/C4', deletes g_ordered machinery, rewrites the C4 counterexample elimination with correct argument roles, proves forward_G/backward_H from correct C4 + C0, and closes all 13 downstream sorry sites. Definition of done: sorry-free dd_countermodel_chronicle with clean `#print axioms`.

### Research Integration

- **Report 25 (team research, DEFINITIVE)**: All four teammates independently confirmed the C4 argument swap. Burgess U(alpha, beta) = codebase untl(beta, alpha) -- arguments are reversed. C4 checks EVENT at f(y) and negates GUARD at f(z). The codebase does the opposite. With correct C4, forward_G is a one-step proof from C4 + C0. g_ordered is unnecessary.

### Prior Plan Reference

Plan v10 (artifact 23) structured work into Phases 0-7 (30 hours). Phases 0-4 completed, establishing: r3Relation infrastructure (sorry-free), three-way C3 (sorry-free), burgessR3_absorption via BX6 (sorry-free), density counterexamples + limit_dom_dense (sorry-free), singleton_invariant (sorry-free). The g_ordered invariant approach from Phase 4 is now superseded -- g_ordered was introduced as a workaround for the broken C4 and is unnecessary with the correct definition. Effort calibration: C4/C4' elimination hard cases consumed more time than estimated; the full Lemma 2.6 seed is complex.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (ROADMAP representation theorem goal)
- The chronicle pathway replaces the blocked RootScopedChain.lean approach
- Closing all 13 sorry sites achieves the representation theorem milestone

## Goals & Non-Goals

**Goals**:
- Fix C4/C4' definitions to match Burgess 1982 (swap EVENT/GUARD roles)
- Delete g_ordered/h_ordered from ChronicleInvariant and omega chain
- Rewrite C4/C4' counterexample elimination with correct argument roles
- Implement Lemma 2.6 full seed for the C4 hard case
- Prove forward_G/backward_H from correct C4 + C0 at the limit
- Prove generalized C4 (non-adjacent) from density + adjacent C4
- Close all ChronicleToCountermodel sorry sites
- Achieve sorry-free dd_countermodel_chronicle
- Maintain lake build success at each phase boundary

**Non-Goals**:
- Investigating g_ordered (confirmed unnecessary with correct C4)
- General completeness for all strict linear orders (stretch goal, separate task)
- Fixing sorry sites outside Chronicle/ directory (task 109 scope)
- Cantor isomorphism for non-domain extension (not needed if limit domain is dense and all rationals become domain points through density elimination)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Lemma 2.6 full seed consistency proof is complex | H | M | The r3Maximal_neg_of_not_mem helper is already sorry-free. The richer seed {neg delta} union B union {beta U gamma} needs careful consistency argument. Paper-proof first. |
| Generalized C4 (non-adjacent pairs) induction is non-trivial | M | M | Density gives intermediate points. Induction on count of domain points between x and y. Each step uses adjacent C4. The argument is standard (Burgess Lemma 2.9). |
| C4 hard case (delta in both f(x) and f(y)) needs full Lemma 2.6 | H | M | With correct C4, the hard case checks delta (EVENT) at f(y), not gamma (GUARD). The sub-case structure changes. The delta-in-g(x,y) vs delta-not-in-g(x,y) split may simplify. |
| Non-domain extension for chronicle_fmcs | M | L | With density elimination, limit_dom is dense in Rat. Extended_limit_f at non-domain points uses A, but forward_G/backward_H only need to work on limit_dom points (transferred via correct C4 + C0). The Cantor isomorphism (Option B) remains as fallback. |
| Downstream wiring in ChronicleToCountermodel has 8 sorry sites | M | L | Once forward_G/backward_H and C5/C5' work at the limit, the wiring is mechanical. Each sorry maps to a specific chronicle property. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Fix C4/C4' Definitions and Delete g_ordered [NOT STARTED]

**Goal**: Swap the C4/C4' definitions to match Burgess 1982 and remove g_ordered/h_ordered from ChronicleInvariant.

**Tasks**:
- [ ] Swap C4 definition: check delta (EVENT, second arg of untl) at f(y), produce gamma.neg (GUARD negation) at f(z)
- [ ] Swap C4' definition: same swap for Since mirror
- [ ] Update C4/C4' docstrings to reflect correct Burgess semantics
- [ ] Remove `hg_ord` and `hh_ord` fields from `ChronicleInvariant` structure
- [ ] Delete `omega_chain_g_ordered` theorem (ChronicleConstruction.lean:842-846)
- [ ] Delete `omega_chain_h_ordered` theorem (ChronicleConstruction.lean:851-855)
- [ ] Update `limit_forward_G` to use a new proof strategy (placeholder sorry, closed in Phase 4)
- [ ] Update `limit_backward_H` to use a new proof strategy (placeholder sorry, closed in Phase 4)
- [ ] Update `singleton_invariant` to remove g_ordered/h_ordered obligations
- [ ] Fix any downstream compilation errors from the ChronicleInvariant field removal
- [ ] Run lake build and verify

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `Chronicle/ChronicleTypes.lean` -- C4/C4' definitions (lines 304-319), ChronicleInvariant (lines 424-447)
- `Chronicle/ChronicleConstruction.lean` -- delete omega_chain_g/h_ordered, rewrite limit_forward_G/backward_H signatures

**Verification**:
- lake build succeeds
- C4 checks delta (EVENT) at f(y), negates gamma (GUARD) at f(z)
- ChronicleInvariant has 4 fields (hc0, hc1, hc2', hc3) -- no g_ordered/h_ordered
- omega_chain_g_ordered and omega_chain_h_ordered deleted (2 sorry sites removed)
- Sorry count: 13 -> 11 (net -2)

---

### Phase 2: Rewrite C4/C4' Counterexample Elimination [NOT STARTED]

**Goal**: Rewrite the C4/C4' elimination functions to use the correct argument roles. With the corrected C4, the elimination must find z with gamma.neg (GUARD negation) instead of delta.neg (EVENT negation). Close the 2 sorry sites in CounterexampleElimination.lean.

**Tasks**:
- [ ] Update C4Counterexample/C4'Counterexample structures to reflect correct field roles (gamma = GUARD, delta = EVENT)
- [ ] Rewrite eliminate_C4_counterexample: the witness z needs gamma.neg in f(z), not delta.neg
- [ ] Paper-proof the hard case (gamma in both f(x) and f(y)) under the correct C4:
  - With correct C4: neg(untl(gamma, delta)) in f(x), delta in f(y), need z with gamma.neg in f(z)
  - Sub-case gamma not in g(x,y): use r3Maximal_neg_of_not_mem to get MCS D with gamma.neg
  - Sub-case gamma in g(x,y): need full Lemma 2.6 seed
- [ ] Implement the hard case for C4 elimination (close sorry at line 282)
- [ ] Mirror for C4' elimination (close sorry at line 348)
- [ ] Implement lemma_2_6_full if needed for the hard sub-case
- [ ] Run lake build and verify

**Timing**: 5 hours

**Depends on**: Phase 1 (correct C4/C4' definitions)

**Files to modify**:
- `Chronicle/CounterexampleElimination.lean` -- C4/C4' elimination functions, counterexample structures
- `Chronicle/PointInsertion.lean` -- lemma_2_6_full (if needed for hard case)

**Verification**:
- lake build succeeds
- eliminate_C4_counterexample sorry-free (produces z with gamma.neg, not delta.neg)
- eliminate_C4'_counterexample sorry-free
- Sorry count: 11 -> 9 (net -2, possibly -3 if lemma_2_6_full also closes)

---

### Phase 3: Prove forward_G/backward_H from Correct C4 + C0 [NOT STARTED]

**Goal**: Prove that G(phi) in f(x) implies phi in f(y) for all x < y in the limit domain, using the correct C4 + C0 contradiction argument. This replaces the deleted g_ordered approach entirely.

**Tasks**:
- [ ] Prove generalized C4 for non-adjacent pairs at the limit:
  - Lemma: for any x < y in limit_dom (not necessarily adjacent), if neg(untl(gamma, delta)) in limit_f(x) and delta in limit_f(y), then exists z in limit_dom with gamma.neg in limit_f(z) and x < z < y
  - Proof by induction on the number of limit_dom points between x and y:
    - Base (adjacent): directly from limit C4
    - Step: density gives intermediate w. Either delta in limit_f(w) (apply induction on (x,w)) or delta.neg in limit_f(w) (done, z=w). But w is in an MCS so exactly one holds.
- [ ] Prove limit_forward_G using generalized C4 + C0:
  - G(phi) = neg(untl(top, phi.neg)) in f(x), so neg(untl(top, phi.neg)) in f(x)
  - Suppose phi.neg in f(y) for some y > x (toward contradiction)
  - phi.neg is the EVENT of untl(top, phi.neg)
  - By generalized C4: exists z with top.neg = bot in f(z)
  - bot in MCS contradicts C0. Contradiction. So phi in f(y).
- [ ] Prove limit_backward_H (mirror using C4' and H = neg(snce(top, phi.neg)))
- [ ] Run lake build and verify

**Timing**: 4 hours

**Depends on**: Phase 1 (correct C4 definition, limit_forward_G/backward_H stubs)

**Files to modify**:
- `Chronicle/ChronicleConstruction.lean` -- limit_forward_G, limit_backward_H, generalized_C4 lemma

**Verification**:
- lake build succeeds
- limit_forward_G sorry-free
- limit_backward_H sorry-free
- Sorry count: 9 -> 7 (net -2, closing the placeholder sorries from Phase 1)

**Note**: This phase does NOT depend on Phase 2 (C4 elimination). The generalized C4 at the limit follows from: (a) adjacent C4 is vacuously true in the dense limit (no adjacent pairs), OR (b) generalized C4 is proved directly from density + C4-completeness of the omega chain. The key insight is that in the dense limit domain, for any x < y there exists z between them, so the C4 property extends by density induction.

---

### Phase 4: Close PointInsertion Sorry (lemma_2_6_full) [NOT STARTED]

**Goal**: Implement the full Lemma 2.6 seed construction for the C4 hard case. This creates an MCS D with delta.neg (under old C4) or gamma.neg (under new C4) using a richer seed than just {neg formula} union B.

**Tasks**:
- [ ] Paper-proof the full Lemma 2.6 seed construction:
  - Seed: {neg gamma} union B union {beta U gamma_f | specific formulas from C context} union {beta S gamma_f | specific formulas from A context}
  - Consistency: from R3Maximality of B, if adding neg gamma made the seed inconsistent, the contradiction gives a derivation that contradicts B's maximality
- [ ] Implement lemma_2_6_full in PointInsertion.lean (close sorry at line 762)
- [ ] Verify that it provides what the C4 hard case needs
- [ ] Run lake build and verify

**Timing**: 3 hours

**Depends on**: Phase 2 (to know what the C4 hard case actually needs from Lemma 2.6)

**Files to modify**:
- `Chronicle/PointInsertion.lean` -- lemma_2_6_full implementation

**Verification**:
- lake build succeeds
- lemma_2_6_full sorry-free
- Sorry count: 7 -> 6 (net -1)

---

### Phase 5: Close ChronicleToCountermodel Sorry Sites [NOT STARTED]

**Goal**: Close all 8 remaining sorry sites in ChronicleToCountermodel.lean. With forward_G/backward_H proved and C5/C5' established at the limit, these become mechanical wiring.

**Tasks**:
- [ ] Close chronicle_fmcs forward_G sorry (line 195): delegate to limit_forward_G via extended_limit_f
- [ ] Close chronicle_fmcs backward_H sorry (line 200): delegate to limit_backward_H
- [ ] Close chronicle_bfmcs_restricted_tc forward sorry (line 372): F(phi) resolution via C5 + density
- [ ] Close chronicle_bfmcs_restricted_tc backward sorry (line 375): P(phi) resolution via C5'
- [ ] Close chronicle_bfmcs_restricted_buc Until sorry (line 394): backward Until from C4 completeness + C3
- [ ] Close chronicle_bfmcs_restricted_buc Since sorry (line 397): mirror
- [ ] Close chronicle_bfmcs_restricted_fuc Until sorry (line 426): forward Until from C5 + C3 guard transfer
- [ ] Close chronicle_bfmcs_restricted_fuc Since sorry (line 429): mirror
- [ ] Wire dd_countermodel_chronicle: verify all coherence conditions compile sorry-free
- [ ] Run lake build and verify with `#print axioms dd_countermodel_chronicle`

**Timing**: 4 hours

**Depends on**: Phase 3 (forward_G/backward_H), Phase 4 (lemma_2_6_full for complete C4 elimination)

**Files to modify**:
- `Chronicle/ChronicleToCountermodel.lean` -- close all 8 sorry sites

**Verification**:
- lake build succeeds
- ChronicleToCountermodel.lean sorry-free
- dd_countermodel_chronicle compiles sorry-free
- `#print axioms dd_countermodel_chronicle` shows no sorryAx
- Sorry count: 6 -> 0
- **Milestone**: Representation theorem achieved

---

### Phase 6: Cleanup and Validation [NOT STARTED]

**Goal**: Final cleanup pass. Remove dead code, verify no regressions, update ROADMAP.md with completion status.

**Tasks**:
- [ ] Remove dead code: deprecated g_content chain ordering definitions, old g_ordered comments, omega_chain_g/h_ordered references
- [ ] Clean up C4/C4' counterexample structure docstrings
- [ ] Verify no regressions: full lake build, check sorry count across entire project
- [ ] Verify axiom audit: `#print axioms dd_countermodel_chronicle` shows only Lean axioms (propfunext, Quot.sound, Classical.choice)
- [ ] Ensure Soundness, FMP, ParametricTruthLemma remain sorry-free
- [ ] Update ROADMAP.md: mark chronicle path as completed, update sorry inventory

**Timing**: 2 hours (primarily validation, not new code)

**Depends on**: Phase 5 (sorry-free dd_countermodel_chronicle)

**Files to modify**:
- `Chronicle/*.lean` -- dead code removal
- `specs/ROADMAP.md` -- completion update

**Verification**:
- lake build succeeds (full clean build)
- Zero sorry sites in Chronicle/ directory
- No regressions in other modules
- ROADMAP.md updated

## Testing & Validation

- [ ] lake build succeeds at each phase boundary (6 checkpoints)
- [ ] Phase 1: C4/C4' definitions match Burgess 1982; ChronicleInvariant simplified; 2 sorries deleted
- [ ] Phase 2: C4/C4' counterexample elimination sorry-free with correct argument roles
- [ ] Phase 3: limit_forward_G/backward_H sorry-free from correct C4 + C0
- [ ] Phase 4: lemma_2_6_full sorry-free
- [ ] Phase 5: ChronicleToCountermodel.lean sorry-free; dd_countermodel_chronicle sorry-free
- [ ] Phase 6: Full clean build; zero sorry in Chronicle/; `#print axioms` clean
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] Each paper-proof step validated before Lean formalization

## Artifacts & Outputs

- `specs/107_.../plans/25_implementation-plan.md` (this file)
- Modified: `Chronicle/ChronicleTypes.lean` (C4/C4' fix, ChronicleInvariant simplification)
- Modified: `Chronicle/CounterexampleElimination.lean` (C4/C4' elimination rewrite)
- Modified: `Chronicle/PointInsertion.lean` (lemma_2_6_full implementation)
- Modified: `Chronicle/ChronicleConstruction.lean` (delete g_ordered, rewrite limit_forward_G/backward_H)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (close all 8 sorry sites)
- Modified: `specs/ROADMAP.md` (completion update)

## Rollback/Contingency

- **Git safety**: The irr_until branch preserves the current state. All changes can be reverted to HEAD.
- **Phase 1 contingency**: If swapping C4 breaks more than expected, the swap is a 2-line change in ChronicleTypes.lean and can be reverted independently.
- **Phase 2 contingency**: If the C4 hard case under the new definition is harder than expected, leave it sorry'd and proceed to Phase 3 (forward_G does not depend on the hard case -- it uses generalized C4 which follows from density making all pairs non-adjacent at the limit).
- **Phase 3 contingency**: If the generalized C4 induction over dense domain is tricky, use the alternative: in the dense limit, there are no adjacent pairs, so C4 for adjacent pairs is vacuously true. Forward_G then uses the direct C0 contradiction argument without needing generalized C4.
- **Phase 4 contingency**: If lemma_2_6_full proves intractable, the C4 hard case can be deferred. Forward_G at the limit does not depend on it (density makes C4 vacuous for adjacent pairs).
- **Phase 5 contingency**: If non-domain extension creates issues, apply Cantor isomorphism (Order.iso_of_countable_dense) to make all rationals domain points, as identified in report 24.
- **Budget overrun**: Phases are independently valuable. Phases 1+3 alone (correct C4 + forward_G) remove the root blocker. Phase 5 is downstream wiring.
