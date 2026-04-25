# Implementation Plan: Task #107 (v10 -- All Blockers Resolved, Final Implementation)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 30 hours
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/23_team-research.md], [reports/23_teammate-b-findings.md], [reports/23_teammate-c-findings.md], [reports/22_teammate-b-findings.md]
- **Artifacts**: plans/23_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Plan v10 incorporates all breakthroughs from research rounds 22-23. Three previously blocking problems are now resolved: (1) A6a IS BX6 after Burgess/BX argument-swap, so Lemma 2.5 absorption works directly; (2) forward_G/backward_H follow from C4 + C0 (consistency), eliminating g_content_chain_property entirely; (3) non-domain extension is solved via density counterexamples + Cantor isomorphism (Order.iso_of_countable_dense). One open question remains (A4a derivability from BX), investigated in Phase 3 before Lemma 2.6. Phases 0-1 carry forward as completed. Phase 2 carries forward as partial (C3 redefined, C2/C2' updated, consequence lemmas added; remaining: g for non-adjacent pairs, delete g_content_chain_property, Lemma 2.5 absorption). Definition of done: sorry-free dd_countermodel_chronicle.

### Research Integration

- **Report 23 (team research, DEFINITIVE)**: A6a = BX6 after argument swap (Teammates A, D). Forward_G from C4 + C0 (Teammate B). Cantor isomorphism for non-domain extension (Teammate C). A4a separation axiom flagged but unverified.
- **Report 22 (team research)**: Three-way C3 discovery (g(x,z) = g(x,y) inter f(y) inter g(y,z)). Complete paper proof of modified omega chain by Teammate B.
- **Teammate B (round 23)**: ChronicleInvariant bundle design (C0, C1, C2', C3). Modified C5/C4 elimination with g-tracking. Correct limit_g as first-stage union. g_content_chain_property eliminated.
- **Teammate C (round 23)**: Cantor isomorphism solution. Subtype limit_dom fails (no AddCommGroup). Interpolation fails (intersection of MCS not MCS). Density + Cantor is the viable path.

### Prior Plan Reference

Plan v9 (22_implementation-plan.md) structured work into Phases 0-5 (30 hours). Phases 0-1 completed (ROADMAP update + three-argument r-relation). Phase 2 began but was partial (C3 redefined, C2/C2' updated). Key lessons: (1) the three-way C3 is correct and the codebase has been updated; (2) g_content_chain_property should be DELETED not proved; (3) the A6a = BX6 equivalence was unknown at v9 time and blocked C2 verification for non-adjacent pairs; (4) forward_G proof strategy was wrong in v9 (used g_content duality, should use C4 + C0). What changes in v10: A6a resolved as BX6, forward_G strategy corrected, non-domain extension solved via Cantor, A4a investigation added, density counterexamples added.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (ROADMAP representation theorem goal)
- The chronicle pathway replaces the blocked RootScopedChain.lean approach
- Phase 0 (ROADMAP update) already completed in v7

## Goals & Non-Goals

**Goals**:
- Complete three-way C3 integration (g on all pairs, Lemma 2.5 absorption via BX6)
- Verify A4a derivability from BX axioms (or add as axiom if needed)
- Implement full Lemma 2.6 (DCS three-way decomposition) for C4 elimination
- Implement ChronicleInvariant bundle + modified omega chain with g-tracking
- Delete g_content_chain_property, prove forward_G/backward_H from C4 + C0
- Add density counterexamples + Cantor isomorphism for non-domain extension
- Close all 12 remaining sorry sites in Chronicle/ directory
- Achieve sorry-free dd_countermodel_chronicle
- Maintain lake build success at each phase boundary

**Non-Goals**:
- Investigating the deterministic chain path (confirmed DEAD)
- Investigating Venema 1993 (eliminated -- requires Burgess as input)
- Making the chronicle domain dense as a semantic requirement (density is a construction tool, not a logical property)
- Fixing sorry sites outside Chronicle/ directory (task 109 scope)
- General completeness for all strict linear orders (stretch goal deferred)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A4a not derivable from BX axioms | H | M | Check derivability first (Phase 3). If not derivable, add as axiom to BX system -- Burgess uses it, so it is sound. Alternatively, restructure Lemma 2.6 to avoid A4a. |
| Full Lemma 2.6 (B' inter D inter B'' = g(x,y)) fails under BX strict semantics | H | L | Paper-prove each step before Lean. Teammate B's round 22 proof outlines the exact argument. The A6a = BX6 confirmation de-risks this significantly. |
| Density counterexample enumeration complicates omega chain invariant | M | M | Density counterexamples are structurally simpler than C4/C5 (just insert a midpoint with Lindenbaum MCS). No new g-value construction needed (C3 defines it). |
| Order.iso_of_countable_dense requires properties not yet proved for limit_dom | M | L | The three required properties (countable, dense, no endpoints) each have straightforward proofs. Countable = union of finite sets. Dense = density counterexamples. No endpoints = C5/C5' witnesses. |
| Discovery of false lemmas during Lean formalization (historical 4/4 rate) | M | H | Paper-proof every step before Lean. Each phase includes explicit paper-proof tasks. The A6a = BX6 confirmation reduces the false lemma surface. |
| Generalized C4 (non-adjacent) needed for forward_G but not directly maintained | M | M | The forward_G argument only needs: for any x < y, if neg(top U neg phi) in f(x) and top in f(y), then exists z with bot in f(z). This contradicts C0 (consistency). The limit C4 for non-adjacent pairs follows from density + adjacent C4 via finite induction on intermediate points. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0, 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |
| 6 | 6 | 5 |
| 7 | 7 | 6 |

Phases within the same wave can execute in parallel.

---

### Phase 0: Update ROADMAP.md [COMPLETED]

**Goal**: Bring ROADMAP.md up to date with chronicle construction findings.

**Tasks**:
- [x] Updated Active Metalogic Path to reflect chronicle as primary completeness path
- [x] Added task 107 and task 112 to Task Cross-Reference
- [x] Updated sorry inventory (12 chronicle sorry sites)
- [x] Documented binary g-function finding and density axiom finding

**Timing**: 2 hours (completed in v7)

**Depends on**: none

**Files modified**:
- `specs/ROADMAP.md` -- completed

**Verification**:
- ROADMAP.md accurately reflects current state

---

### Phase 1: Three-Argument r-Relation and R-Maximality [COMPLETED]

**Goal**: Define the three-argument r-relation r(A, B, C) per Burgess Lemma 2.3 and prove existence of R-maximal three-argument extensions via Zorn's lemma.

**Tasks**:
- [x] Defined r3Relation, r3RelationSince, R3Maximal, R3MaximalSince
- [x] Proved bridge lemmas r3->r2
- [x] Added to ChronicleTypes.lean and RRelation.lean

**Timing**: 10 hours (completed in v8)

**Depends on**: none

**Files modified**:
- `Chronicle/ChronicleTypes.lean` -- completed
- `Chronicle/RRelation.lean` -- completed

**Verification**:
- lake build succeeds
- r3Relation, R3Maximal defined and type-check
- Bridge lemmas sorry-free

---

### Phase 2: Complete Three-Way C3 Integration [COMPLETED]

**Goal**: Finish the three-way C3 integration. The C3 definition, C2/C2' updates, and ValidChronicle structure are already in place. Remaining: define g for non-adjacent pairs via C3, prove Lemma 2.5 absorption using BX6 (absorb_until), delete g_content_chain_property.

**Tasks**:
- [x] Redefine Chronicle.c3 as three-way intersection (done in prior phase)
- [x] Update Chronicle.c2 to use r3Relation (done)
- [x] Add ValidChronicle structure with C0-C5 fields (done)
- [x] Add c3 consequence lemmas (interval subset point/left/right) (done)
- [ ] **Define g-for-all-pairs helper**: When the Chronicle structure is extended with a new point, non-adjacent g values are DEFINED by C3 iteration. Add `chronicle_g_nonadjacent` that computes g(x,z) = g(x,y) inter f(y) inter g(y,z) for the unique adjacent decomposition.
- [ ] **Paper-prove and formalize Lemma 2.5 absorption**: For delta in g(x,z) = g(x,y) inter f(y) inter g(y,z) and gamma in f(z): (1) delta in g(y,z), so U(gamma, delta) in f(y) by r3(f(y), g(y,z), f(z)); (2) delta in f(y), so delta AND U(gamma, delta) in f(y); (3) delta in g(x,y), so U(delta AND U(gamma,delta), delta) in f(x) by r3(f(x), g(x,y), f(y)); (4) by BX6 (absorb_until): U(gamma, delta) in f(x). This proves r3Relation(f(x), g(x,z), f(z)) from adjacent C2' + C3.
- [ ] **Prove C2 for all pairs from C2' + C3 + BX6**: General theorem `c2_of_c2_prime_and_c3` using iterated Lemma 2.5 absorption.
- [ ] **DELETE g_content_chain_property**: Remove the sorry at ChronicleConstruction.lean:741. Replace with a comment explaining that C3 provides the needed truth lemma path directly.
- [ ] Run lake build and verify

**Timing**: 6 hours (3 hours remaining of estimated 6)

**Depends on**: Phase 1 (r3Relation definitions)

**Files to modify**:
- `Chronicle/ChronicleTypes.lean` -- add g-for-all-pairs helper
- `Chronicle/RRelation.lean` -- add Lemma 2.5 absorption theorem (r3_from_c3_absorption)
- `Chronicle/ChronicleConstruction.lean` -- delete g_content_chain_property sorry (line 741)

**Verification**:
- lake build succeeds
- Lemma 2.5 absorption proved sorry-free using BX6 (absorb_until)
- C2 derived from C2' + C3 + BX6 (sorry-free)
- g_content_chain_property sorry DELETED
- Sorry count: 12 -> 11

---

### Phase 3: Verify A4a + Implement Full Lemma 2.6 [PARTIAL]

**Goal**: Verify A4a derivability from BX axioms, then implement the full Lemma 2.6 (DCS three-way decomposition) needed for C4 elimination. A4a is the separation axiom: (q U p) and not(r U p) implies q U (q and not r). Burgess uses it in Lemma 2.6.

**Tasks**:
- [ ] **Check A4a against BX axioms**: After argument swap, A4a becomes `(q U p) AND NOT(r U p) -> q U (q AND NOT r)`. Check if this is derivable from BX1-BX12. Key approach: try BX7 (linear_until) with the two Until formulas; BX2 (left_mono_until) for guard strengthening; BX5 (self_accum_until) for self-enrichment. If derivable, formalize the derivation. If not derivable, either (a) add as axiom to BX, or (b) find an alternative proof of Lemma 2.6 that avoids A4a.
- [ ] **Paper-prove full Lemma 2.6**: Given R3Maximal(A, B, C) and delta not in B, produce B', D, B'' with: neg(delta) in D, R3Maximal(A, B', D), R3Maximal(D, B'', C), B = B' inter D inter B''. Key steps: (a) show {neg delta} union relevant content is consistent; (b) extend to MCS D; (c) define B' = R3Maximal(A, -, D) from appropriate seed; (d) define B'' = R3Maximal(D, -, C) from appropriate seed; (e) prove B = B' inter D inter B'' via Lemma 2.5 pattern.
- [ ] **Implement Lemma 2.6 Until direction**: `theorem lemma_2_6_until (A C : Set Formula) (h_A : SetMaximalConsistent A) (h_C : SetMaximalConsistent C) (B : Set Formula) (h_R : R3Maximal A B C) (delta : Formula) (h_not : delta notin B) : exists B' D B'', ...`
- [ ] **Implement Lemma 2.6 Since direction** (mirror)
- [ ] Run lake build and verify

**Timing**: 6 hours

**Depends on**: Phase 2 (Lemma 2.5 absorption, C2 from C2' + C3)

**Files to modify**:
- `Chronicle/PointInsertion.lean` -- add full Lemma 2.6 (with B' inter D inter B'')
- `Chronicle/RRelation.lean` -- add A4a derivation or axiom if needed

**Verification**:
- lake build succeeds
- A4a either derived from BX or added as axiom (with soundness argument)
- Lemma 2.6 proved sorry-free (both Until and Since directions)
- Sorry count unchanged (no sorry sites closed yet, infrastructure only)

---

### Phase 4: ChronicleInvariant + Modified Omega Chain [NOT STARTED]

**Goal**: Implement ChronicleInvariant bundle, modify C4/C5 elimination to track g values, rebuild the omega chain to maintain C0/C1/C2'/C3 at every stage. Add density counterexamples to the enumeration.

**Tasks**:
- [ ] **Define ChronicleInvariant structure**: Bundle of C0, C1, C2', C3 (C2 derived via Phase 2's theorem). Add to ChronicleTypes.lean.
- [ ] **Prove singleton_invariant**: The singleton chronicle {0} satisfies ChronicleInvariant vacuously (no pairs, no triples).
- [ ] **Define EliminationResult with g-tracking**: New structure requiring dom_sub, invariant preservation, f_agrees (old f unchanged), g_agrees (old g unchanged), plus counterexample resolution.
- [ ] **Modify eliminate_C5_counterexample**: Apply existing Lemma 2.4 to get MCS C and R3-maximal B. Set f'(y) = C, g'(x,y) = B. For w < x: g'(w,y) = g(w,x) inter f(x) inter B (C3 definition). Verify ChronicleInvariant.
- [ ] **Modify eliminate_C4_counterexample**: Apply full Lemma 2.6 from Phase 3. Set z = midpoint, f'(z) = D, g'(x,z) = B', g'(z,y) = B''. For other pairs: define by C3. Verify g(x,y) = B' inter D inter B'' = g'(x,z) inter f'(z) inter g'(z,y) (Lemma 2.5 consistency). Close the 2 sorry sites at CounterexampleElimination.lean lines 289 and 355.
- [ ] **Add density counterexample kind**: For each adjacent pair (x,y) in dom, enumerate a request to insert midpoint z = (x+y)/2 with f(z) = Lindenbaum(g_content(f(x)) union h_content(f(y))), g values defined by C3.
- [ ] **Remove g_prop counterexample kinds**: Delete g_prop_forward and g_prop_backward from PotentialCounterexampleKind (no longer needed with C3).
- [ ] **Rebuild omega_chain**: Return type changes from `{chi // chi.c0}` to `{chi // ChronicleInvariant chi}`. Each step applies the appropriate elimination and returns a chronicle satisfying the full invariant.
- [ ] **Prove g-immutability**: Each elimination step preserves g values for existing pairs.
- [ ] Run lake build and verify

**Timing**: 6 hours

**Depends on**: Phase 3 (Lemma 2.6)

**Files to modify**:
- `Chronicle/ChronicleTypes.lean` -- add ChronicleInvariant, EliminationResult, density counterexample kind, remove g_prop kinds
- `Chronicle/CounterexampleElimination.lean` -- rewrite C4/C5 elimination with g-tracking, close 2 sorry sites (lines 289, 355)
- `Chronicle/ChronicleConstruction.lean` -- rebuild omega_chain with ChronicleInvariant return type

**Verification**:
- lake build succeeds
- ChronicleInvariant maintained at every omega chain step
- CounterexampleElimination.lean sorry-free (lines 289, 355 closed)
- g-immutability proved
- Density counterexamples enumerated
- Sorry count: 11 -> 9

---

### Phase 5: Limit Construction + Cantor Isomorphism [NOT STARTED]

**Goal**: Redefine limit_g correctly, prove limit_dom density properties, apply Cantor isomorphism to map every rational to a domain point. Close limit_backward_H sorry and delete limit_g's reliance on g_content_chain_property.

**Tasks**:
- [ ] **Redefine limit_g**: limit_g(x,y) = g_n(x,y) for the first n where both x,y are in dom_n. Well-definedness follows from g-immutability (Phase 4).
- [ ] **Prove limit C3**: For x < y < z all in limit_dom, get n with all three in dom_n, use C3 at stage n + g/f immutability.
- [ ] **Prove limit_dom properties**: (a) limit_dom_countable (union of finite sets), (b) limit_dom_dense (from density counterexamples in Phase 4), (c) limit_dom_no_min/no_max (from C5'/C5 witnesses), (d) limit_dom_nonempty.
- [ ] **Apply Order.iso_of_countable_dense**: Get `cantor_iso : Subtype limit_dom ≃o Rat`. Redefine `extended_limit_f(q) = limit_f(cantor_iso.symm(q).val)` so every rational maps to a domain point.
- [ ] **Prove forward_G from C4 + C0**: G(phi) in f(x), suppose neg(phi) in f(y) for y > x. Then G(phi) = neg(top U neg phi) in f(x), and top in f(y). By generalized C4 (from adjacent C4 + density): exists z between x and y with neg(top) = bot in f(z). But f(z) is MCS, hence consistent -- contradiction. Therefore phi in f(y).
- [ ] **Prove backward_H from C4' + C0**: Symmetric argument using Since direction.
- [ ] **Prove generalized C4 for limit**: For non-adjacent x < y, by density there exist intermediate domain points. Finite induction on intermediate points, using adjacent C4 at each step.
- [ ] **Close limit_backward_H sorry**: Now follows from backward_H (proved above).
- [ ] Run lake build and verify

**Timing**: 5 hours

**Depends on**: Phase 4 (ChronicleInvariant omega chain, density counterexamples, correct limit_g)

**Files to modify**:
- `Chronicle/ChronicleConstruction.lean` -- redefine limit_g, prove limit C3, limit_dom properties, Cantor iso, forward_G/backward_H, close limit_backward_H sorry
- `Chronicle/ChronicleTypes.lean` -- possibly add limit-level type definitions

**Verification**:
- lake build succeeds
- limit_g well-defined (sorry-free)
- limit C3 proved sorry-free
- Cantor isomorphism applied
- forward_G and backward_H proved sorry-free from C4 + C0
- ChronicleConstruction.lean sorry-free
- Sorry count: 9 -> 8 (limit_backward_H closed)

---

### Phase 6: Wire ChronicleToCountermodel Sorry Sites [NOT STARTED]

**Goal**: Close all 9 sorry sites in ChronicleToCountermodel.lean. With the correct C0-C3 invariants, forward_G/backward_H, and the Cantor isomorphism, the FMCS/BFMCS construction compiles sorry-free.

**Tasks**:
- [ ] **Prove forward_G for FMCS (line 195)**: Use the forward_G from Phase 5 transferred through the Cantor isomorphism. For all t < t' in Rat: cantor_iso.symm preserves order, so limit_f(cantor_iso.symm(t)) to limit_f(cantor_iso.symm(t')) satisfies g-content propagation.
- [ ] **Prove backward_H for FMCS (line 200)**: Symmetric using backward_H from Phase 5.
- [ ] **Prove box_stable (line 238)**: All chronicle MCS are box-equivalent to root A by construction. PointInsertion preserves modal content (already sorry-free infrastructure).
- [ ] **Prove restricted_tc F (line 324)**: Use limit_F_resolution (already sorry-free) to extract witness, transfer to FMCS coordinates via Cantor iso.
- [ ] **Prove restricted_tc P (line 327)**: Mirror using limit_P_resolution.
- [ ] **Prove restricted_buc Until (line 346)**: Backward Until coherence. neg(gamma U delta) in chronicle_fmcs(t): by C4 completeness of the limit, for any witness y > t with delta in f(y) and guard gamma on (t,y), exists z with neg(gamma) in f(z). Route through C3 three-way intersection for intermediate guard argument.
- [ ] **Prove restricted_buc Since (line 349)**: Mirror.
- [ ] **Prove restricted_fuc Until (line 378)**: Forward Until coherence. gamma U delta in chronicle_fmcs(t): C5 gives witness y with delta in f(y) and gamma in g(t,y). C3 gives gamma in f(z) for intermediate z (since g(t,y) subset f(z) by C3). Use BX9 bridge for half-open guard.
- [ ] **Prove restricted_fuc Since (line 381)**: Mirror.
- [ ] **Wire dd_countermodel_chronicle**: Verify all coherence conditions satisfied, countermodel compiles sorry-free.
- [ ] Run lake build and verify with `#print axioms dd_countermodel_chronicle`

**Timing**: 5 hours

**Depends on**: Phase 5 (sorry-free ChronicleConstruction, Cantor iso, forward_G/backward_H)

**Files to modify**:
- `Chronicle/ChronicleToCountermodel.lean` -- close all 9 sorry sites

**Verification**:
- lake build succeeds
- ChronicleToCountermodel.lean sorry-free
- dd_countermodel_chronicle compiles sorry-free
- `#print axioms dd_countermodel_chronicle` shows no sorryAx
- Sorry count: 8 -> 0
- **Milestone**: Representation theorem achieved

---

### Phase 7: Cleanup and Validation [NOT STARTED]

**Goal**: Final cleanup pass. Remove dead code, verify no regressions, update ROADMAP.md with completion status.

**Tasks**:
- [ ] **Remove dead code**: Delete any remaining g_prop-related definitions, old g_content_chain_property comments/references, obsolete counterexample kinds.
- [ ] **Verify no regressions**: Full lake build, check sorry count across entire project. Ensure Soundness, FMP, ParametricTruthLemma remain sorry-free.
- [ ] **Verify axiom audit**: `#print axioms dd_countermodel_chronicle` must show only Lean axioms (propfunext, Quot.sound, Classical.choice) and no sorryAx.
- [ ] **Update ROADMAP.md**: Mark chronicle path as completed, update sorry inventory, note task 109 BXCanonical sorries become non-critical.

**Timing**: 2 hours (reduced -- primarily validation, not new code)

**Depends on**: Phase 6 (sorry-free dd_countermodel_chronicle)

**Files to modify**:
- `Chronicle/*.lean` -- dead code removal
- `specs/ROADMAP.md` -- completion update

**Verification**:
- lake build succeeds (full clean build)
- Zero sorry sites in Chronicle/ directory
- No regressions in other modules
- ROADMAP.md updated

## Testing & Validation

- [ ] lake build succeeds at each phase boundary (Phases 2-7, 6 checkpoints)
- [ ] Phase 2: Lemma 2.5 absorption sorry-free using BX6; g_content_chain_property DELETED
- [ ] Phase 3: A4a resolved (derived or added); Lemma 2.6 sorry-free
- [ ] Phase 4: ChronicleInvariant maintained; CounterexampleElimination.lean sorry-free; density counterexamples added
- [ ] Phase 5: Cantor isomorphism applied; forward_G/backward_H sorry-free from C4+C0; ChronicleConstruction.lean sorry-free
- [ ] Phase 6: ChronicleToCountermodel.lean sorry-free; dd_countermodel_chronicle sorry-free
- [ ] Phase 7: Full clean build; zero sorry in Chronicle/; #print axioms clean
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] Each paper-proof step validated before Lean formalization

## Artifacts & Outputs

- `specs/107_.../plans/23_implementation-plan.md` (this file)
- Modified: `Chronicle/ChronicleTypes.lean` (ChronicleInvariant, EliminationResult, density counterexample)
- Modified: `Chronicle/RRelation.lean` (Lemma 2.5 absorption, A4a derivation)
- Modified: `Chronicle/PointInsertion.lean` (full Lemma 2.6)
- Modified: `Chronicle/CounterexampleElimination.lean` (g-value construction, close 2 sorries)
- Modified: `Chronicle/ChronicleConstruction.lean` (rebuild omega chain, correct limit_g, Cantor iso, forward_G/backward_H, delete g_content_chain_property)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (close all 9 sorries)
- Modified: `specs/ROADMAP.md` (completion update)

## Rollback/Contingency

- **Git safety**: The irr_until branch preserves the current state. All changes can be reverted to HEAD.
- **Phase 2 contingency**: If Lemma 2.5 absorption proof encounters unexpected BX6 form mismatch, verify the argument swap (Burgess U(event, guard) vs BX guard U event) and adjust the BX6 application accordingly.
- **Phase 3 contingency**: If A4a is not derivable from BX, add it as a new axiom. It is used by Burgess and is sound for all linear temporal structures. The axiom addition is localized (one new constructor in Axioms.lean) and soundness proof is straightforward.
- **Phase 4 contingency**: If the full ChronicleInvariant is too complex to maintain during elimination, use the minimal invariant (C0, C1_adj, C2', C3) from Teammate B's analysis, deriving C1 and C2 for all pairs at the limit level only.
- **Phase 5 contingency**: If Order.iso_of_countable_dense has unexpected Mathlib API issues, use the alternative approach: augment limit_dom post-hoc with Lindenbaum extensions at gap points (Teammate C's "minimal fix").
- **Budget overrun**: Phases are independently valuable. Phases 0-4 alone (ChronicleInvariant + sorry-free CounterexampleElimination) are major progress. Phase 5 (Cantor iso + forward_G) is the next milestone. Phase 6 is downstream wiring.
