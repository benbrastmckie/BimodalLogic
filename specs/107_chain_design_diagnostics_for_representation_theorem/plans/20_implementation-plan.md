# Implementation Plan: Task #107 (v8 -- Three-Argument r-Relation and Lemma 2.6 Rebuild)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 85 hours
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/20_team-research.md], [reports/20_teammate-a-findings.md], [reports/17_team-research.md]
- **Artifacts**: plans/20_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan (v8) incorporates breakthrough findings from the Burgess 1982 paper reading (report 20). The entire chronicle construction has been operating on a fundamental misunderstanding: C3 is a DEFINITION (not a property to prove), the r-relation must be THREE-argument r(A, B, C) (not two-argument), and Lemma 2.6 (DCS three-way decomposition) is the key missing construction for C4 elimination. The plan restructures the chronicle around these corrected foundations: redefine the r-relation as three-argument, implement Lemma 2.6, maintain C0-C3 as omega-chain invariants with g values constructed at insertion time via C3, then wire the downstream sorry sites. Phase 0 (ROADMAP update from v7) is carried forward as completed. The 12 remaining sorry sites (1 in ChronicleConstruction, 2 in CounterexampleElimination, 9 in ChronicleToCountermodel) all cascade from the architectural errors this plan corrects. Definition of done: sorry-free `dd_countermodel_chronicle`.

### Research Integration

- **Report 20 (team research)**: BREAKTHROUGH -- C3 is definitional, r-relation is three-argument, Lemma 2.6 is the key missing construction, seed does NOT include g_content, point insertion MUST construct g values. Deterministic chain confirmed DEAD (14+ sorries, 3 structural blockers).
- **Report 20 Teammate A (Burgess paper extraction)**: Full paper reading. Extracted precise definitions of C0-C5, r(A, B, C), R(A, B, C), Lemma 2.4 seed = {gamma} union {S(alpha, beta) : alpha in A}, Lemma 2.6 three-way decomposition, Lemma 2.9 C4 elimination procedure, Claim 2.11 truth lemma mechanism.
- **Report 17 (binary g root cause)**: Identified that g function must be binary g(x,y), not unary g_content(f(x)). Confirmed by report 20's finding that g values are constructed at insertion time and non-adjacent pairs are defined by C3.

### Prior Plan Reference

Plan v7 (17_implementation-plan.md) structured work around binary g rebuild with C2/C3 invariants. Phase 0 (ROADMAP update) was completed. Phase 1 (binary g rebuild, 30h) was partially started. Key lessons: (1) the two-argument r-relation is architecturally wrong -- Burgess uses three-argument r(A, B, C) involving BOTH endpoints; (2) Lemma 2.6 (DCS three-way decomposition) is completely missing and is the workhorse of C4 elimination; (3) g values for new points must be CONSTRUCTED at insertion time, not left unchanged; (4) C3 defines g for non-adjacent pairs -- it is not a property to prove; (5) the 4/4 false lemma rate demands paper-proofing before Lean formalization.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (ROADMAP representation theorem goal)
- The chronicle pathway replaces the blocked RootScopedChain.lean approach (5 critical-path sorry sites become dead code)
- Phase 0 (ROADMAP update) already completed in v7

## Goals & Non-Goals

**Goals**:
- Redefine r-relation as three-argument r(A, B, C) per Burgess 2.3
- Implement Lemma 2.6 (DCS three-way decomposition): given R(A, B, C) and ~delta not in B, produce B', D, B'' with R(A, B', D), R(D, B'', C), B = B' intersect D intersect B''
- Maintain C0-C3 as omega-chain invariants (not just C0)
- Construct g values at point insertion time: g'(x,z), g'(z,y) from Lemma 2.6 for C4 elimination; g'(x_last,y) from Lemma 2.4 for C5 elimination; all non-adjacent g' values defined by C3
- Define limit_g from the maintained C3 invariant (intersection decomposition, not deductiveClosure)
- Close all 12 remaining sorry sites in Chronicle/ directory
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` success at each phase boundary

**Non-Goals**:
- Investigating the deterministic chain path (confirmed DEAD with 14+ sorries)
- Making the chronicle domain dense (validates GGp->Gp, wrong for general completeness)
- Fixing sorry sites outside Chronicle/ directory (task 109 scope)
- Modifying the BX axiom system
- Building a direct truth lemma over sparse X (stretch goal deferred to v9)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Three-argument r-relation breaks existing sorry-free RRelation.lean lemmas | H | M | The two-argument lemmas remain valid as a special case. Add r3 alongside rRelation, migrate incrementally. Existing rMaximal_extension_exists may need a three-argument variant. |
| Lemma 2.6 proof in Lean is mathematically subtle (three-way DCS decomposition) | H | M | Paper-prove the full argument before formalizing. Lemma 2.6 depends on Lemma 2.5 (seed consistency) and Zorn's lemma (existing infrastructure). Break into sub-lemmas. |
| C3 as invariant requires tracking g on ALL pairs, not just adjacent | H | M | Define g on all ordered pairs. For adjacent pairs, g is R-maximal from construction. For non-adjacent pairs, g is DEFINED as intersection via C3. The Chronicle structure already has g : Rat -> Rat -> Set Formula on all pairs. |
| Truth lemma "by C3 we have g(x,y) subset f(z)" step is not fully understood | M | H | Teammate A's analysis (MEDIUM confidence on this step). The three-argument r-relation may provide the missing link: r(f(x), g(x,z), f(z)) combined with DCS properties. Budget extra time for this derivation. |
| Discovery of additional false lemmas during implementation | M | H | Budget 25% contingency. Paper-prove ALL claims before investing in Lean formalization. The 4/4 false lemma history demands extreme caution. |
| R-maximality for three-argument r needs new Zorn's lemma application | M | L | The existing rMaximal_extension_exists pattern (Zorn on DCS extensions) generalizes directly. The third argument C is a parameter, not an optimization target. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2 | 1 |
| 4 | 3 | 2 |
| 5 | 4 | 3 |
| 6 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 0: Update ROADMAP.md [COMPLETED]

**Goal**: Bring ROADMAP.md up to date with chronicle construction findings.

**Tasks**:
- [x] Updated Active Metalogic Path to reflect chronicle as primary completeness path
- [x] Added task 107 and task 112 to Task Cross-Reference
- [x] Updated sorry inventory (12 chronicle sorry sites)
- [x] Documented binary g-function finding and density axiom finding
- [x] Clarified representation theorem goal

**Timing**: 2 hours (completed in v7)

**Depends on**: none

**Files to modify**:
- `specs/ROADMAP.md` -- completed

**Verification**:
- ROADMAP.md accurately reflects current state

---

### Phase 1: Three-Argument r-Relation and R-Maximality [COMPLETED]

**Goal**: Define the three-argument r-relation r(A, B, C) per Burgess Lemma 2.3 and prove existence of R-maximal three-argument extensions via Zorn's lemma. This is the foundation for all subsequent phases.

**Tasks**:
- [ ] **Paper-prove r3 definition**: r(A, B, C) means for all beta in B, for all gamma in C, U(gamma, beta) in A. Verify this matches Burgess 2.3(a): "for all gamma in C, U(gamma, beta) in A". Write the Lean definition.
- [ ] **Define r3Relation**: `r3Relation (A B C : Set Formula) : Prop` where for all beta in B, for all gamma in C, U(gamma, beta) in A.
- [ ] **Define r3RelationSince**: Mirror for Since direction.
- [ ] **Define R3Maximal**: B is maximal DCS with r3Relation A B C. Structure: SetDeductivelyClosed B, r3Relation A B C, and no proper DCS extension satisfies r3Relation A - C.
- [ ] **Prove r3_seed_consistent**: The seed {beta} union consequences is consistent when U(gamma, beta) in A for gamma in C. This is Burgess Lemma 2.2/2.5 adapted.
- [ ] **Prove r3Maximal_extension_exists**: Given MCS A, C and DCS S with r3Relation A S C, there exists R3-maximal B extending S. Adapt existing Zorn's lemma pattern from rMaximal_extension_exists.
- [ ] **Prove bridge lemma**: r3Relation A B C implies rRelation A B (the two-argument version is a weakening). This preserves all existing sorry-free infrastructure.
- [ ] **Prove r3 monotonicity**: r3Relation A B C and B subset B' implies r3Relation A B' C (for DCS B').
- [ ] Run `lake build` and verify no regressions

**Timing**: 10 hours

**Depends on**: Phase 0

**Files to modify**:
- `Chronicle/ChronicleTypes.lean` -- add r3Relation, r3RelationSince, R3Maximal definitions
- `Chronicle/RRelation.lean` -- add r3Maximal_extension_exists, bridge lemmas, seed consistency

**Verification**:
- `lake build` succeeds
- r3Relation, R3Maximal defined and type-check
- r3Maximal_extension_exists proved sorry-free
- Bridge lemma r3->r2 proved sorry-free
- All existing sorry-free lemmas unchanged

---

### Phase 2: Lemma 2.6 (DCS Three-Way Decomposition) [NOT STARTED]

**Goal**: Implement Burgess Lemma 2.6: given R(A, B, C) and ~delta not in B, produce B', D, B'' such that ~delta in D and R(A, B', D), R(D, B'', C), and B = B' intersect D intersect B''. This is the workhorse of C4 elimination.

**Tasks**:
- [ ] **Paper-prove Lemma 2.6 in full**: Write out the complete proof on paper before Lean formalization. Key steps: (1) extend B union {~delta} to an MCS D; (2) define B' = B intersect D (claim: r3Relation A B' D holds); (3) define B'' = B intersect D (adjusted for C endpoint); (4) prove R-maximality of B', B''. Verify each step is sound.
- [ ] **Prove seed consistency for D**: {~delta} union B-content is consistent (since ~delta not in B and B is a DCS, adding ~delta to deductive closure of B does not derive bot -- this needs careful argument since B is a DCS not an MCS).
- [ ] **Implement lemma_2_6**: `theorem lemma_2_6 (A C : Set Formula) (h_A : SetMaximalConsistent A) (h_C : SetMaximalConsistent C) (B : Set Formula) (h_R : R3Maximal A B C) (delta : Formula) (h_not : delta.neg ∉ B) : exists B' D B'', ...`
- [ ] **Prove the three-way intersection**: B = B' intersect D intersect B''. This is the key structural property.
- [ ] **Prove R-maximality of outputs**: R3Maximal A B' D and R3Maximal D B'' C.
- [ ] **Mirror for Since direction**: Implement the Since-direction variant of Lemma 2.6.
- [ ] Run `lake build` and verify

**Timing**: 15 hours

**Depends on**: Phase 1 (r3Relation, R3Maximal definitions)

**Files to modify**:
- `Chronicle/PointInsertion.lean` -- add lemma_2_6 and its mirror
- `Chronicle/RRelation.lean` -- supporting lemmas for DCS intersection properties

**Verification**:
- `lake build` succeeds
- lemma_2_6 proved sorry-free
- Three-way intersection B = B' intersect D intersect B'' proved
- R-maximality of outputs proved
- All existing sorry-free lemmas unchanged

---

### Phase 3: Chronicle Invariants and g-Value Construction [NOT STARTED]

**Goal**: Rebuild the Chronicle structure to maintain C0-C3 as omega-chain invariants. Modify counterexample elimination to construct g values at insertion time using Lemma 2.6 (C4) and Lemma 2.4 (C5). Define g for non-adjacent pairs via C3.

**Tasks**:
- [ ] **Redefine Chronicle.c2 using r3Relation**: Change `c2` from `rRelation (f x) (g x y)` to `r3Relation (f x) (g x y) (f y)` for adjacent x < y. Similarly update c2' to use R3Maximal.
- [ ] **Redefine Chronicle.c3 as intersection identity**: Change from `g_content (f x) subset g x y` to the true C3: for x < y < z all in dom, `g x y = g x z inter g y z`. This is Burgess's actual C3.
- [ ] **Add Chronicle.c3_extended**: For non-adjacent pairs, g(x,y) is DEFINED as the intersection chain through intermediate points. Add a condition that g on non-adjacent pairs equals the intersection decomposition of adjacent-pair g values.
- [ ] **Modify eliminate_C4_counterexample**: When inserting z between adjacent x and y to refute neg(gamma U delta):
  - Apply Lemma 2.6 to R(f(x), g(x,y), f(y)) and ~delta to get B', D, B''
  - Set f'(z) = D (an MCS with ~delta in D)
  - Set g'(x,z) = B' (satisfying R(f(x), B', D))
  - Set g'(z,y) = B'' (satisfying R(D, B'', f(y)))
  - For all other w in dom: g'(w,z) defined by C3 intersection with g(w,x) and g'(x,z)
  - Prove C0-C3 maintained for the extended chronicle
- [ ] **Modify eliminate_C4'_counterexample**: Mirror for Since direction.
- [ ] **Modify eliminate_C5_counterexample**: When inserting y beyond x for U(xi, eta):
  - Apply Lemma 2.4 to A = f(x) to get B, C with R(f(x), B, C) and xi in C, eta in B
  - Set f'(y) = C, g'(x,y) = B
  - For all other w < x in dom: g'(w,y) defined by C3: g'(w,y) = g(w,x) inter g'(x,y)
  - Prove C0-C3 maintained
- [ ] **Modify eliminate_C5'_counterexample**: Mirror for Since direction.
- [ ] **Prove omega-chain invariant**: The combined invariant (C0 + C1 + C2 + C2' + C3) is preserved by each elimination step. This replaces the current approach of maintaining only C0.
- [ ] **Define limit_g via C3**: For x < y in limit_dom, define limit_g(x,y) as the stabilized g value from the omega-chain. For non-adjacent x,y in the limit, limit_g(x,y) = intersection over the C3 decomposition chain. Prove this is well-defined.
- [ ] **Close g_content_chain_property**: With three-argument r-relation and C2 invariant: for x < y, r3Relation(f(x), g(x,y), f(y)) holds. This means for all beta in g(x,y), for all gamma in f(y), U(gamma, beta) in f(x). The g_content subset relationship follows from the r-relation connecting the interval to both endpoints.
- [ ] **Close limit_backward_H**: Follows from g_content_chain_property via the sorry-free duality bridge.
- [ ] Run `lake build` and verify

**Timing**: 25 hours

**Depends on**: Phase 2 (Lemma 2.6 for C4 elimination)

**Files to modify**:
- `Chronicle/ChronicleTypes.lean` -- update c2, c3 definitions to use r3Relation and intersection identity
- `Chronicle/CounterexampleElimination.lean` -- rebuild all four elimination functions with g-value construction
- `Chronicle/ChronicleConstruction.lean` -- close g_content_chain_property (line 748) and limit_backward_H, redefine limit_g

**Verification**:
- `lake build` succeeds
- g_content_chain_property sorry-free
- limit_backward_H sorry-free
- C0-C3 invariant maintained through all elimination steps
- Sorry count: 12 -> 10 (closed: g_content_chain_property, limit_backward_H)

---

### Phase 4: Close CounterexampleElimination Sorry Sites [NOT STARTED]

**Goal**: Close the 2 remaining sorry sites in CounterexampleElimination.lean (C4 sub-case 1a lines 289, 355). With Lemma 2.6 from Phase 2 and the three-argument r-relation from Phase 1, these should fall out from the restructured C4 elimination.

**Tasks**:
- [ ] **Analyze C4 sub-case 1a**: The current sorry at line 289 handles the case where delta is in both endpoints. With Lemma 2.6, this case is handled uniformly: R(f(x), g(x,y), f(y)) with ~delta not in g(x,y) (since delta in f(y) and g(x,y) is a DCS consistent with r3). Apply Lemma 2.6 directly.
- [ ] **Paper-prove the sub-case**: Verify that Lemma 2.6 applies when delta in f(x) and delta in f(y). The condition is ~delta not in B (= g(x,y)). Since g(x,y) is a DCS and delta in f(y), we need to check that ~delta is not forced into g(x,y). Paper-prove this.
- [ ] **Close C4 sub-case 1a (Until)**: Formalize the paper proof at line 289.
- [ ] **Close C4' sub-case 1a (Since)**: Mirror at line 355.
- [ ] Run `lake build` and verify

**Timing**: 8 hours

**Depends on**: Phase 3 (restructured C4 elimination with Lemma 2.6)

**Files to modify**:
- `Chronicle/CounterexampleElimination.lean` -- close 2 sorry sites (lines 289, 355)

**Verification**:
- `lake build` succeeds
- CounterexampleElimination.lean is sorry-free
- Sorry count: 10 -> 8

---

### Phase 5: Wire Downstream Sorry Sites in ChronicleToCountermodel [NOT STARTED]

**Goal**: Close all 9 sorry sites in ChronicleToCountermodel.lean. With the correct chronicle invariants (C0-C3, three-argument r-relation, g-value construction) from Phases 1-4, these should cascade from the now-correct foundations.

**Tasks**:
- [ ] **Prove forward_G (line 192)**: For domain points: G(phi) in limit_f(x) implies phi in g_content(limit_f(x)), and g_content_chain_property (now sorry-free from Phase 3) gives phi in limit_f(y) for y > x. For non-domain points: design the extension strategy (subtype FMCS over limit_dom, or nearest-point interpolation).
- [ ] **Prove backward_H (line 196)**: Follows from limit_backward_H (now sorry-free from Phase 3) via the duality bridge.
- [ ] **Prove box_stable (line 234)**: All chronicle MCS are box-equivalent to root A by construction. PointInsertion preserves modal content. Prove Box(phi) in A iff Box(phi) in limit_f(x) for all x.
- [ ] **Prove restricted_tc F (line 320)**: Use limit_F_resolution (already sorry-free) to extract witness, transfer to shifted FMCS coordinates.
- [ ] **Prove restricted_tc P (line 323)**: Mirror using limit_P_resolution.
- [ ] **Prove restricted_buc Until (line 342)**: Backward Until coherence. Given neg(gamma U delta) in chronicle_fmcs(t) but guard and witness exist, derive contradiction via C4 completeness of the limit chronicle.
- [ ] **Prove restricted_buc Since (line 345)**: Mirror using C4'.
- [ ] **Prove restricted_fuc Until (line 374)**: Forward Until coherence. Given gamma U delta in chronicle_fmcs(t), use C5 completeness with BX9 bridge (until_elim gives phi or psi at the origin point) to extract half-open guard witness.
- [ ] **Prove restricted_fuc Since (line 377)**: Mirror using C5'.
- [ ] **Wire dd_countermodel_chronicle**: Verify that all coherence conditions are satisfied and the countermodel construction compiles sorry-free.
- [ ] Run `lake build` and verify with `#print axioms dd_countermodel_chronicle`

**Timing**: 25 hours

**Depends on**: Phase 4 (sorry-free CounterexampleElimination, all invariants established)

**Files to modify**:
- `Chronicle/ChronicleToCountermodel.lean` -- close all 9 sorry sites

**Verification**:
- `lake build` succeeds
- ChronicleToCountermodel.lean is sorry-free
- `dd_countermodel_chronicle` compiles sorry-free
- `#print axioms dd_countermodel_chronicle` shows no sorryAx
- Sorry count: 8 -> 0
- **Milestone**: Representation theorem achieved

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary (5 checkpoints)
- [ ] Phase 1: r3Relation, R3Maximal defined; r3Maximal_extension_exists sorry-free; bridge r3->r2 sorry-free
- [ ] Phase 2: lemma_2_6 sorry-free; three-way intersection proved; R-maximality of outputs proved
- [ ] Phase 3: C0-C3 omega-chain invariant maintained; g_content_chain_property sorry-free; limit_backward_H sorry-free; sorry count 12 -> 10
- [ ] Phase 4: CounterexampleElimination.lean sorry-free; sorry count 10 -> 8
- [ ] Phase 5: ChronicleToCountermodel.lean sorry-free; `#print axioms dd_countermodel_chronicle` clean; sorry count 8 -> 0
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] Each paper-proof step validated before Lean formalization (given 4/4 false lemma rate)

## Artifacts & Outputs

- `specs/107_.../plans/20_implementation-plan.md` (this file)
- Modified: `Chronicle/ChronicleTypes.lean` (r3Relation, updated c2/c3 definitions)
- Modified: `Chronicle/RRelation.lean` (r3Maximal_extension_exists, bridge lemmas)
- Modified: `Chronicle/PointInsertion.lean` (lemma_2_6, since mirror)
- Modified: `Chronicle/CounterexampleElimination.lean` (g-value construction, close 2 sorries)
- Modified: `Chronicle/ChronicleConstruction.lean` (close g_content_chain_property, limit_backward_H; redefine limit_g)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (close all 9 sorries)

## Rollback/Contingency

- **Git safety**: The `irr_until` branch preserves the current state. All changes can be reverted to HEAD.
- **Phase 1 contingency**: If three-argument r-relation is hard to integrate, keep the two-argument version alongside and add r3 as a separate layer. The bridge lemma ensures no regression.
- **Phase 2 contingency**: If Lemma 2.6 paper proof reveals a gap, investigate whether the existing PointInsertion lemmas (2.4, 2.7) can be combined to achieve a weaker form of three-way decomposition sufficient for C4 elimination.
- **Phase 3 contingency**: If maintaining C3 as an invariant through ALL elimination steps is too invasive, maintain C3 only for adjacent pairs and define non-adjacent g via C3 after the fact (post-hoc C3 assignment rather than inductive invariant).
- **Phase 5 contingency**: If the extended_limit_f replacement for non-domain points is too invasive, accept a weaker result: completeness restricted to the chronicle domain (a strict linear order), rather than completeness for Rat. The chronicle domain result is independently valuable.
- **Budget overrun**: Phases are independently valuable. Phase 1-2 alone (three-argument r-relation + Lemma 2.6) is significant infrastructure. Phase 3 closing g_content_chain_property is the key milestone. Phases 4-5 are downstream wiring.
