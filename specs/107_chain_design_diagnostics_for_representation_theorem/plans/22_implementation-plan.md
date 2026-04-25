# Implementation Plan: Task #107 (v9 -- Three-Way C3 and Truth Lemma via Direct Intersection)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 30 hours
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/22_team-research.md], [reports/22_teammate-b-findings.md]
- **Artifacts**: plans/22_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

Plan v9 incorporates the definitive breakthrough from report 22: Burgess's C3 is a THREE-WAY intersection `g(x,z) = g(x,y) cap f(y) cap g(y,z)`, with the `f(y)` factor omitted in all previous analysis. With the correct C3, the truth lemma's "g(x,y) subset f(z)" step for intermediate z is IMMEDIATE, g_content_chain_property is NOT NEEDED (delete it), and C2 verification after point insertion uses the A6a/BX6 absorption pattern from Lemma 2.5. The plan redefines C3 as a three-way intersection, extends g to all pairs (non-adjacent defined by C3), rebuilds point insertion to construct g values via C3, deletes g_content_chain_property, and wires the downstream sorry sites through C3-based arguments. Phase 0 (ROADMAP update) and Phase 1 (three-argument r-relation) carry forward as completed from v8. Definition of done: sorry-free `dd_countermodel_chronicle`.

### Research Integration

- **Report 22 (team research, DEFINITIVE)**: C3 is three-way `g(x,z) = g(x,y) cap f(y) cap g(y,z)`. The f(y) factor was omitted in all analysis rounds 1-21. With correct C3: truth lemma routes through C3 directly, g_content_chain_property is not needed, C2 after insertion uses A6a absorption (Lemma 2.5 pattern). Venema 1993 eliminated (requires Burgess as input, targets well-orderings).
- **Report 22 Teammate B (complete paper proof)**: Full paper proof of the modified omega-chain construction. Verified C3 against paper markdown line 207. Proved C2 verification after insertion via A6a absorption: delta in g'(w,y), gamma in C gives U(gamma,delta) in f(x) by r(f(x),B,C); then delta AND U(gamma,delta) in f(x); then r(f(w),g(w,x),f(x)) gives U(delta AND U(gamma,delta), delta) in f(w); then A6a gives U(gamma,delta) in f(w).

### Prior Plan Reference

Plan v8 (20_implementation-plan.md) structured work into 6 phases (0-5, 85 hours). Phase 0 (ROADMAP update, 2h) completed. Phase 1 (three-argument r-relation, 10h) completed -- r3Relation, R3Maximal, bridge lemmas all sorry-free. Phases 2-5 were NOT STARTED. Key lessons from v8: (1) the 85-hour estimate was inflated because it assumed g_content_chain_property was the critical bottleneck; with three-way C3, that sorry dissolves; (2) Phase 2 (Lemma 2.6) was correctly identified as essential for C4 elimination; (3) the 4/4 false lemma rate demands paper-proofing before Lean. What changes in v9: C3 is now three-way (not two-way), g_content_chain_property is deleted rather than proved, total effort reduced from 85h to 30h.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (ROADMAP representation theorem goal)
- The chronicle pathway replaces the blocked RootScopedChain.lean approach
- Phase 0 (ROADMAP update) already completed in v7

## Goals & Non-Goals

**Goals**:
- Redefine C3 as three-way intersection: `g(x,z) = g(x,y) cap f(y) cap g(y,z)` for all x < y < z in dom
- Extend g to ALL pairs (x,y) with x < y, not just adjacent pairs
- DELETE g_content_chain_property sorry (replace with C3-based truth lemma path)
- Implement Lemma 2.6 (DCS three-way decomposition) for C4 elimination
- Modify point insertion to construct g values for new pairs via C3
- Prove C2 for non-adjacent pairs after insertion using A6a/BX6 absorption (Lemma 2.5 pattern)
- Close all 12 remaining sorry sites in Chronicle/ directory
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` success at each phase boundary

**Non-Goals**:
- Investigating the deterministic chain path (confirmed DEAD)
- Investigating Venema 1993 (eliminated -- requires Burgess as input)
- Making the chronicle domain dense (validates GGp->Gp, wrong for general completeness)
- Fixing sorry sites outside Chronicle/ directory (task 109 scope)
- General completeness for all strict linear orders (stretch goal deferred)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| A6a/BX6 absorption argument fails under BX strict semantics | H | M | Paper-prove the absorption step (Lemma 2.5 pattern) under BX axioms before Lean formalization. Teammate B's paper proof outlines the exact steps; verify `absorb_until` provides the needed `U(q AND U(p,q), q) -> U(p,q)` form. |
| Three-way C3 intersection type-checks but g for non-adjacent pairs creates universe issues | M | L | g is already typed as Rat -> Rat -> Set Formula on all pairs. Non-adjacent g values are defined by C3 intersection, which stays in the same universe. |
| Lemma 2.6 (DCS three-way decomposition) is mathematically subtle in Lean | H | M | Paper-prove the full argument first. Key dependency: Lemma 2.5 (intersection identity). Both use the A6a absorption argument. Break into sub-lemmas with independent verification. |
| Extended limit_f for non-domain points requires Option B (restrict to limit_dom) | M | M | Accept restricted completeness over chronicle domain X (a strict linear order) as a fallback. The chronicle domain result is independently valuable. |
| Discovery of false lemmas during Lean formalization (historical 4/4 rate) | M | H | Budget paper-proof step before every Lean formalization. Each phase includes explicit paper-proof tasks before code. |
| C2' (R-maximality for adjacent pairs) lost during C3 redefinition | M | L | C2' is only required for adjacent pairs. Point insertion constructs R-maximal g for adjacent pairs (Lemmas 2.4, 2.6). Non-adjacent pairs only need C2 (r-relation), not C2' (R-maximality). |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0, 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |
| 5 | 5 | 4 |

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

**Files to modify**:
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

**Files to modify**:
- `Chronicle/ChronicleTypes.lean` -- completed
- `Chronicle/RRelation.lean` -- completed

**Verification**:
- `lake build` succeeds
- r3Relation, R3Maximal defined and type-check
- Bridge lemmas sorry-free

---

### Phase 2: Redefine C3 and Extend g to All Pairs [PARTIAL]

**Goal**: Replace the current wrong C3 definition with the correct three-way intersection. Extend g from adjacent-only to all pairs, with non-adjacent g values defined by C3. This is the foundational change that unblocks everything.

**Tasks**:
- [ ] **Paper-prove C3 consistency**: Verify that defining g(x,z) = g(x,y) cap f(y) cap g(y,z) for all x < y < z is well-defined (i.e., the result is independent of the choice of intermediate y when multiple intermediates exist). This follows from associativity of the three-way intersection when C3 holds at all triples.
- [ ] **Redefine Chronicle.c3**: Change from the current `g_content(f(x)) subset g(x,y)` to the true C3: for all x < y < z in dom, `g(x,z) = g(x,y) inter f(y) inter g(y,z)`.
- [ ] **Define g for non-adjacent pairs**: When the Chronicle structure is extended, g on non-adjacent pairs (x,z) with intermediate y is DEFINED as `g(x,y) inter f(y) inter g(y,z)`. Add a helper that computes g for any pair from the C3 chain.
- [ ] **Update Chronicle.c2 to use r3Relation**: Change `c2` from `rRelation (f x) (g x y)` to `r3Relation (f x) (g x y) (f y)` for all x < y in dom (not just adjacent).
- [ ] **Prove C2 for non-adjacent pairs from C3 + adjacent C2**: Paper-prove, then formalize: if r3Relation(f(x), g(x,y), f(y)) and r3Relation(f(y), g(y,z), f(z)) hold for adjacent pairs, and g(x,z) = g(x,y) cap f(y) cap g(y,z), then r3Relation(f(x), g(x,z), f(z)). This is the A6a absorption argument from Lemma 2.5.
- [ ] **Prove the Lemma 2.5 absorption pattern**: For delta in g(x,z) = g(x,y) cap f(y) cap g(y,z) and gamma in f(z): (1) delta in g(y,z), so U(gamma, delta) in f(y) by r3(f(y), g(y,z), f(z)); (2) delta in f(y), so delta AND U(gamma, delta) in f(y); (3) delta in g(x,y), so U(delta AND U(gamma,delta), delta) in f(x) by r3(f(x), g(x,y), f(y)); (4) by BX6 (absorb_until): U(gamma, delta) in f(x). QED.
- [ ] **DELETE g_content_chain_property**: Remove the sorry at ChronicleConstruction.lean:748. Replace with a comment explaining that C3 provides the needed truth lemma path directly.
- [ ] Run `lake build` and verify

**Timing**: 8 hours

**Depends on**: Phase 1 (r3Relation definitions)

**Files to modify**:
- `Chronicle/ChronicleTypes.lean` -- redefine c2, c3; add g-for-all-pairs infrastructure
- `Chronicle/RRelation.lean` -- add Lemma 2.5 absorption theorem (r3_from_c3_absorption)
- `Chronicle/ChronicleConstruction.lean` -- delete g_content_chain_property sorry (line 748), update limit_g definition

**Verification**:
- `lake build` succeeds
- C3 is three-way intersection (not g_content subset)
- g defined on all pairs via C3 chain
- Lemma 2.5 absorption proved sorry-free
- g_content_chain_property sorry DELETED (not proved -- deleted)
- Sorry count: 12 -> 11 (deleted g_content_chain_property)

---

### Phase 3: Rebuild Point Insertion and Counterexample Elimination [NOT STARTED]

**Goal**: Modify C4 and C5 elimination to construct g values for ALL new pairs (not just adjacent) when inserting a point. Implement Lemma 2.6 (DCS three-way decomposition) for C4 elimination. Close the 2 sorry sites in CounterexampleElimination.lean.

**Tasks**:
- [ ] **Paper-prove Lemma 2.6 under BX strict semantics**: Given R3Maximal(A, B, C) and delta not in B, produce B', D, B'' with: neg(delta) in D, R3Maximal(A, B', D), R3Maximal(D, B'', C), B = B' cap D cap B''. Key sub-steps: (a) show {neg delta} union B-derived content is consistent; (b) extend to MCS D; (c) define B' as maximal DCS with B subset B' and r3(A, B', D); (d) define B'' similarly; (e) prove B = B' cap D cap B'' via Lemma 2.5.
- [ ] **Implement Lemma 2.6**: `theorem lemma_2_6 (A C : Set Formula) (h_A : SetMaximalConsistent A) (h_C : SetMaximalConsistent C) (B : Set Formula) (h_R : R3Maximal A B C) (delta : Formula) (h_not : delta ∉ B) : exists B' D B'', ...`
- [ ] **Implement Lemma 2.6 Since mirror**: For the Since direction.
- [ ] **Modify eliminate_C4_counterexample**: Apply Lemma 2.6 to R(f(x), g(x,y), f(y)) to get B', D, B''. Set f'(z) = D, g'(x,z) = B', g'(z,y) = B''. For all w < x: g'(w,z) = g(w,x) cap f(x) cap g'(x,z) [C3 definition]. For all w > y: g'(z,w) = g'(z,y) cap f(y) cap g(y,w). Prove C0-C3 for extended chronicle.
- [ ] **Close C4 sub-case 1a Until (line 289)**: With Lemma 2.6 and three-way C3, this case is handled uniformly.
- [ ] **Close C4 sub-case 1a Since (line 355)**: Mirror.
- [ ] **Modify eliminate_C5_counterexample**: Apply Lemma 2.4 to get B, C with R(f(x), B, C). Set f'(y) = C, g'(x,y) = B. For all w < x: g'(w,y) = g(w,x) cap f(x) cap g'(x,y) [C3 definition]. Prove C0-C3 for extended chronicle.
- [ ] **Prove omega-chain C0-C3 invariant**: The combined invariant is preserved by each elimination step. This replaces maintaining only C0.
- [ ] Run `lake build` and verify

**Timing**: 10 hours

**Depends on**: Phase 2 (three-way C3, g on all pairs, Lemma 2.5 absorption)

**Files to modify**:
- `Chronicle/PointInsertion.lean` -- add lemma_2_6 and Since mirror
- `Chronicle/CounterexampleElimination.lean` -- rebuild C4/C5 elimination with g-value construction, close 2 sorry sites (lines 289, 355)
- `Chronicle/ChronicleConstruction.lean` -- update omega-chain to maintain C0-C3 invariant, redefine limit_g

**Verification**:
- `lake build` succeeds
- Lemma 2.6 proved sorry-free
- CounterexampleElimination.lean sorry-free (lines 289, 355 closed)
- C0-C3 invariant maintained through all elimination steps
- Sorry count: 11 -> 9

---

### Phase 4: Close ChronicleConstruction Sorry Sites [NOT STARTED]

**Goal**: Close the remaining sorry site in ChronicleConstruction.lean (limit_backward_H) and verify limit construction integrity. With C0-C3 invariant from Phase 3, limit_g is well-defined and limit_backward_H follows from the C3-based g(x,y) subset f(z) property.

**Tasks**:
- [ ] **Paper-prove limit_backward_H**: With the three-way C3 in the limit: for x < z < y, g(x,y) = g(x,z) cap f(z) cap g(z,y), so g(x,y) subset f(z). H(phi) in f(y) with phi in g(x,y) (via r-relation) gives phi in f(z) for all z between x and y. This is the backward direction.
- [ ] **Close limit_backward_H**: Formalize using C3 subset property and r3Relation on the limit.
- [ ] **Verify limit_g definition**: Ensure limit_g for non-adjacent pairs in the limit domain is defined consistently by the omega-chain C3 invariant. For x < y with intermediate z, limit_g(x,y) = limit_g(x,z) cap limit_f(z) cap limit_g(z,y).
- [ ] **Handle extended_limit_f for non-domain points**: Decide between Option A (extend f to all rationals via nearest-point interpolation) and Option B (restrict completeness to chronicle domain X). Option B is simpler and independently valuable; prefer it unless Option A is straightforward.
- [ ] Run `lake build` and verify

**Timing**: 4 hours

**Depends on**: Phase 3 (C0-C3 invariant, sorry-free CounterexampleElimination)

**Files to modify**:
- `Chronicle/ChronicleConstruction.lean` -- close limit_backward_H, verify limit_g, handle non-domain extension

**Verification**:
- `lake build` succeeds
- ChronicleConstruction.lean sorry-free
- Sorry count: 9 -> 8 (or 9->8 if limit_backward_H was the only remaining sorry here)

---

### Phase 5: Wire Downstream Sorry Sites in ChronicleToCountermodel [NOT STARTED]

**Goal**: Close all 9 sorry sites in ChronicleToCountermodel.lean. With the correct C0-C3 invariants and three-way C3, these cascade from the now-correct foundations. The truth lemma uses C3 directly: for U(beta, gamma) in f(x), C5a gives witness y with gamma in f(y) and beta in g(x,y); for intermediate z, C3 gives g(x,y) subset f(z), so beta in f(z).

**Tasks**:
- [ ] **Paper-prove the truth lemma U-case**: (Forward) U(beta,gamma) in f(x). C5a: exists y > x with gamma in f(y), beta in g(x,y). For z with x < z < y: C3 gives g(x,y) = g(x,z) cap f(z) cap g(z,y), so g(x,y) subset f(z), so beta in f(z). By induction: gamma at y, beta at all intermediate z. (Backward) neg U(beta,gamma) in f(x). For any y with gamma in f(y): C4a gives z with x < z < y and neg(beta) in f(z).
- [ ] **Prove forward_G (line 192)**: G(phi) in limit_f(x). For y > x: by C3 (three-way), g(x,y) subset f(z) for intermediate z. Combined with r3Relation giving phi in g(x,y), phi in f(y) follows from the limit's C5/C4 completeness. Route through the U-case via G = neg F neg.
- [ ] **Prove backward_H (line 196)**: Mirror of forward_G using Since direction. Follows from limit_backward_H (Phase 4) and the C3 subset property.
- [ ] **Prove box_stable (line 234)**: All chronicle MCS are box-equivalent to root A by construction. PointInsertion preserves modal content (already proved sorry-free in existing infrastructure).
- [ ] **Prove restricted_tc F (line 320)**: Use limit_F_resolution (already sorry-free) to extract witness, transfer to shifted FMCS coordinates.
- [ ] **Prove restricted_tc P (line 323)**: Mirror using limit_P_resolution.
- [ ] **Prove restricted_buc Until (line 342)**: Backward Until coherence. neg(gamma U delta) in chronicle_fmcs(t) but guard and witness exist: derive contradiction via C4 completeness. The C3 three-way intersection makes the intermediate-guard argument trivial.
- [ ] **Prove restricted_buc Since (line 345)**: Mirror.
- [ ] **Prove restricted_fuc Until (line 374)**: Forward Until coherence. gamma U delta in chronicle_fmcs(t): C5 gives witness y with delta in f(y) and gamma in g(t,y). C3 gives gamma in f(z) for intermediate z. Use BX9 bridge for half-open guard.
- [ ] **Prove restricted_fuc Since (line 377)**: Mirror.
- [ ] **Wire dd_countermodel_chronicle**: Verify all coherence conditions satisfied, countermodel compiles sorry-free.
- [ ] Run `lake build` and verify with `#print axioms dd_countermodel_chronicle`

**Timing**: 6 hours

**Depends on**: Phase 4 (sorry-free ChronicleConstruction, limit construction complete)

**Files to modify**:
- `Chronicle/ChronicleToCountermodel.lean` -- close all 9 sorry sites

**Verification**:
- `lake build` succeeds
- ChronicleToCountermodel.lean sorry-free
- `dd_countermodel_chronicle` compiles sorry-free
- `#print axioms dd_countermodel_chronicle` shows no sorryAx
- Sorry count: 8 -> 0
- **Milestone**: Representation theorem achieved

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary (4 checkpoints: Phases 2, 3, 4, 5)
- [ ] Phase 2: C3 is three-way intersection; Lemma 2.5 absorption sorry-free; g_content_chain_property DELETED
- [ ] Phase 3: Lemma 2.6 sorry-free; CounterexampleElimination.lean sorry-free; C0-C3 invariant maintained
- [ ] Phase 4: ChronicleConstruction.lean sorry-free; limit_g well-defined
- [ ] Phase 5: ChronicleToCountermodel.lean sorry-free; `#print axioms dd_countermodel_chronicle` clean
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] Each paper-proof step validated before Lean formalization (given 4/4 false lemma rate)

## Artifacts & Outputs

- `specs/107_.../plans/22_implementation-plan.md` (this file)
- Modified: `Chronicle/ChronicleTypes.lean` (three-way C3, g on all pairs)
- Modified: `Chronicle/RRelation.lean` (Lemma 2.5 absorption)
- Modified: `Chronicle/PointInsertion.lean` (Lemma 2.6)
- Modified: `Chronicle/CounterexampleElimination.lean` (g-value construction, close 2 sorries)
- Modified: `Chronicle/ChronicleConstruction.lean` (delete g_content_chain_property, close limit_backward_H, redefine limit_g)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (close all 9 sorries)

## Rollback/Contingency

- **Git safety**: The `irr_until` branch preserves the current state. All changes can be reverted to HEAD.
- **Phase 2 contingency**: If C3 redefinition breaks too many downstream definitions, introduce three-way C3 as a SEPARATE condition alongside existing c3, migrate incrementally, then remove old c3.
- **Phase 3 contingency**: If Lemma 2.6 paper proof reveals a gap under BX strict semantics, investigate whether the existing PointInsertion lemmas (2.4, 2.7) can provide a weaker decomposition sufficient for C4 elimination.
- **Phase 5 contingency**: If non-domain extension (extended_limit_f) is too invasive, accept completeness restricted to the chronicle domain X (a strict linear order). The chronicle domain result is independently valuable and the representation theorem goal (D=Rat) may be achievable by embedding X into Rat.
- **Budget overrun**: Phases are independently valuable. Phase 2 alone (three-way C3 + delete g_content_chain_property) is significant progress. Phase 3 (Lemma 2.6 + close CounterexampleElimination) is the next milestone. Phases 4-5 are downstream wiring.
