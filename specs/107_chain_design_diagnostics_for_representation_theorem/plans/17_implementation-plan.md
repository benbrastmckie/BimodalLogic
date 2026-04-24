# Implementation Plan: Task #107 (v7 -- Binary g Rebuild with ROADMAP Update)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 102 hours
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/11_team-research.md], [reports/16_team-research.md], [reports/17_team-research.md]
- **Artifacts**: plans/17_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan (v7) rebuilds the chronicle construction around Burgess's actual binary g(x,y) function, replacing the architecturally wrong unary g that was the root cause of the g_content_chain_property sorry and all downstream blockers. Report 17 established that the current `limit_g(x,y) = deductiveClosure(g_content(limit_f(x)))` is a function of x only, whereas Burgess 1982 uses a binary interval function g(x,y) maintained through the omega-chain with the decomposition identity C3: `g(x,z) = g(x,y) intersect f(y) intersect g(y,z)`. Plan v6 attempted to fix this via enlarged elimination seeds (carrying g_content of all predecessors), but the Phase 1 handoff found a consistency gap: F(eta) does not propagate through g_content, making the enlarged seed potentially inconsistent.

The plan has three tracks. Phase 0 updates the stale ROADMAP.md. Track 1 (Phases 1-4) rebuilds the chronicle with binary g and closes 13 sorry sites to achieve a sorry-free `dd_countermodel_chronicle` over the sparse domain X (the representation theorem: TM is complete w.r.t. TaskFrames over totally ordered abelian groups). Track 2 (Phase 5) builds a direct BFMCS truth lemma over sparse X for general completeness over all strict linear orders. The 102-hour budget reflects the high false-lemma discovery rate (4/4 PointInsertion lemmas were false in earlier plans, plus the g_content_chain_property consistency gap from plan v6).

### Research Integration

- **Report 11** (density analysis): Dense domain WRONG for general completeness. GGp->Gp valid on Q but not derivable in BX. Burgess uses sparse X subset Q. Reversed report 10's recommendation.
- **Report 16** (critical evaluation): Chronicle IS the right path. Escapes Lindenbaum opacity via controlled PointInsertion. All gaps are engineering, not mathematical impossibilities. Hybrid Int-chain + enriched seed is dead end (#7, #13, #23, #31). Budget 100h given discovery rate.
- **Report 17** (binary g root cause): The codebase's g function is architecturally wrong -- unary (function of x only) when Burgess uses binary g(x,y). The fix: rebuild omega-chain to maintain (f, g) pairs with C3 as maintained invariant. When inserting z between x and y, g(x,y) splits into g(x,z) and g(z,y). The g_content chain property then falls out from C2+C3.

### Prior Plan Reference

Plan v6 (16_implementation-plan.md) structured work as 5 phases around modified elimination seeds. Phase 1 was partially attempted (Phase 1 handoff): limit_c1_at_domain closed, duality bridge g_content<->h_content proved sorry-free, but g_content_chain_property blocked by consistency gap in the enlarged seed approach (F(eta) does not propagate through g_content). Key lessons: (1) enlarged elimination seeds have a fundamental consistency gap -- the approach from v6 Phase 1 cannot work; (2) the unary g function is the root cause, not the seed design; (3) binary g(x,y) maintained through the omega-chain is the correct Burgess construction; (4) sorry count is now 13 (down from 14, limit_c1_at_domain closed). Plan v7 replaces Phase 1 entirely with a binary g rebuild and carries forward Phases 2-5 with adjustments.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (ROADMAP representation theorem goal)
- The chronicle pathway in ChronicleToCountermodel.lean replaces the blocked RootScopedChain.lean approach (5 critical-path sorry sites become dead code)
- Phase 0 updates the stale ROADMAP to reflect chronicle as active completeness path
- Phase 5 extends beyond the ROADMAP goal to achieve completeness for all strict linear orders

## Goals & Non-Goals

**Goals**:
- Update ROADMAP.md to reflect current state (chronicle path, binary g finding, density axiom, sorry count)
- Rebuild Chronicle structure to carry binary g(x,y) between adjacent domain points
- Modify eliminate_potential_counterexample to return updated g (split when inserting between adjacent points)
- Maintain C2 (R-relation) and C3 (decomposition) through omega-chain steps
- Define limit_g as the limit of the binary g through the omega-chain
- Prove g_content_chain_property from C2+C3 (the critical bottleneck)
- Resolve guard convention mismatch via BX9 bridge
- Replace the provably-false extended_limit_f with a correct construction
- Close all 13 remaining sorry sites in the Chronicle/ directory
- Achieve sorry-free `dd_countermodel_chronicle` (Path B: Rat-based representation theorem)
- Build direct BFMCS truth lemma over sparse X for general completeness (Path A)
- Maintain `lake build` success at each phase boundary

**Non-Goals**:
- Refactoring TaskFrame to remove AddCommGroup (15-25 days, breaks 3000 lines of sorry-free code)
- Making the chronicle domain dense (validates GGp->Gp, wrong for general completeness)
- Fixing sorry sites outside the Chronicle/ directory (task 109 scope)
- Modifying the BX axiom system
- Proving decidability/FMP results (separate track)
- Revisiting hybrid Int-chain + enriched seed approach (dead ends #7, #13, #23, #31)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Binary g type design is hard to integrate with existing Chronicle structure | H | M | Start with paper design of the new types. ChronicleTypes.lean is ~200 lines; complete rewrite is feasible. Keep the existing unary g infrastructure until the binary replacement compiles. |
| g-splitting when inserting z between adjacent x and y is mathematically subtle | H | M | Study Burgess 1982 Section 2 carefully. The PointInsertion lemmas (lemma_2_4, lemma_2_6) already construct MCS from controlled seeds -- the g-split follows the same pattern. Paper-prove the split preserves C2/C3 before formalizing. |
| C3 decomposition identity is hard to maintain through arbitrary omega-chain insertions | H | M | The decomposition only applies to ADJACENT triples. When z is inserted between adjacent x and y, only g(x,y) is split. Non-adjacent pairs decompose via chaining through intermediates. Track adjacency explicitly in the Chronicle structure. |
| C4 sub-case 1a (delta in both endpoints) is a false lemma | H | M | Paper-validate first. If false, restructure C4 elimination to route through g-function + C3. Pattern of false lemmas warrants extreme caution. |
| extended_limit_f replacement introduces new architectural complexity | M | M | Design alternatives up front. The ROADMAP goal (totally ordered abelian groups) matches D=Rat. Accept GGp->Gp for Path B if needed; general completeness comes from Path A (Phase 5). |
| Discovery of additional false lemmas during implementation | M | H | Budget 30% contingency. Paper-prove claims before investing in Lean formalization. Use MCP lean_verify for quick checks. |
| Phase 1 (30h) exceeds estimate due to type-level complexity of binary g | H | M | Binary g can be defined as a function on ordered pairs of adjacent domain elements. If adjacency tracking is too complex, fall back to defining g on ALL pairs with the invariant that only adjacent-pair values matter. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1 | 0 |
| 3 | 2, 3 | 1 |
| 4 | 4 | 2, 3 |
| 5 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 0: Update ROADMAP.md [COMPLETED]

**Goal**: Bring the stale ROADMAP.md (last updated 2026-04-20) up to date with current findings from the chronicle construction effort.

**Tasks**:
- [ ] Update the "Active Metalogic Path" section to reflect that the chronicle construction (task 107) is the active completeness path, alongside the existing BXCanonical chain
- [ ] Add task 107 and task 112 to the Task Cross-Reference table
- [ ] Update sorry inventory: chronicle module has 13 sorry sites (limit_c1_at_domain closed, 2 in ChronicleConstruction, 2 in CounterexampleElimination, 9 in ChronicleToCountermodel)
- [ ] Document the binary g-function finding (report 17): current unary g is architecturally wrong, binary g(x,y) with C3 decomposition is the correct Burgess construction
- [ ] Document the density axiom finding (report 11): GGp->Gp valid on Q but not derivable in BX, dense domain is wrong for general completeness, Burgess uses sparse X subset Q
- [ ] Add dead end #37 assessment: chronicle is NOT a dead end (all gaps are engineering problems, not mathematical impossibilities per report 16)
- [ ] Clarify representation theorem goal: D=Rat completeness IS the stated goal ("TaskFrames over totally ordered abelian groups"), general completeness is a stretch goal
- [ ] Note that the hybrid Int-chain approach (dead ends #7/#13/#31) should NOT be revisited
- [ ] Update the "Recommended Priority Order" to include chronicle as the primary completeness path
- [ ] Update the "last updated" timestamp

**Timing**: 2 hours

**Depends on**: none

**Files to modify**:
- `specs/ROADMAP.md` -- comprehensive update reflecting chronicle findings

**Verification**:
- ROADMAP.md accurately reflects current state
- Task 107 appears in cross-reference table
- Sorry counts are consistent with codebase
- No false claims about dead ends or approach viability

---

### Phase 1: Rebuild Binary g Function [NOT STARTED]

**Goal**: Redefine the Chronicle structure to carry a binary g(x,y) function between adjacent domain points, modify the omega-chain step to maintain (f, g) pairs with C2 and C3 as invariants, define limit_g as the limit of the binary g, and prove g_content_chain_property from the maintained invariants. This replaces plan v6's enlarged-seed approach which was blocked by a consistency gap.

**Tasks**:
- [ ] **Paper-design the binary g type**: Define how g(x,y) is represented in Lean. Options: (a) function `dom -> dom -> Set Formula` with adjacency constraint, (b) function on `AdjPair dom` subtype, (c) finitely-supported function (Finsupp) since dom is finite at each stage. Choose the simplest option that integrates with ChronicleTypes.
- [ ] **Redefine ChronicleTypes**: Add binary g to the Chronicle structure. Each Chronicle now carries `g_interval : dom -> dom -> Set Formula` alongside `f : dom -> Set Formula`. Add C2 (R-relation) and C3 (decomposition) to the ChronicleProperty invariant.
  - C2: For adjacent x < y in dom, g_content(f(x)) subset g_interval(x, y)
  - C3: For x < y < z in dom with y adjacent to both x and z, g_interval(x, z) = g_interval(x, y) intersect f(y) intersect g_interval(y, z)
- [ ] **Define initial g for singleton/base chronicle**: For the initial chronicle with root point x0, g_interval is trivially defined (no adjacent pairs or a single identity).
- [ ] **Modify eliminate_C5_counterexample to update g**: When C5 elimination inserts point z beyond existing domain for U(xi, eta) at x:
  - New f(z) is constructed via PointInsertion (existing)
  - New g_interval(x_last, z) = deductiveClosure(g_content(f(x_last))) where x_last is the last domain point before z
  - Prove C2 for the new pair (x_last, z)
  - Prove C3 is maintained (no intermediate points disturbed)
- [ ] **Modify eliminate_C5'_counterexample**: Mirror for Since/Past direction.
- [ ] **Modify eliminate_C4_counterexample to split g**: When C4 elimination inserts z between adjacent x and y for neg(gamma U delta):
  - New f(z) is constructed via PointInsertion (existing)
  - g_interval(x, y) is SPLIT into g_interval(x, z) and g_interval(z, y)
  - g_interval(x, z) must satisfy C2 w.r.t. f(x): g_content(f(x)) subset g_interval(x, z)
  - g_interval(z, y) must satisfy C2 w.r.t. f(z): g_content(f(z)) subset g_interval(z, y)
  - Prove the split preserves C3: the old g_interval(x, y) decomposes via f(z)
  - The PointInsertion seed for f(z) includes g_content(f(x)), which gives C2 for (x, z) by construction
- [ ] **Modify eliminate_C4'_counterexample**: Mirror.
- [ ] **Prove omega-chain inductive invariant**: At each stage n, C2 and C3 hold for all adjacent pairs in dom_n. Base case: trivial. Inductive step: the modified elimination functions preserve C2 and C3.
- [ ] **Define limit_g from binary g**: limit_g_interval(x, y) = g_n_interval(x, y) for the first n where x and y are adjacent in dom_n. Handle adjacency changes: when z is inserted between x and y at stage m > n, g_n_interval(x, y) is replaced by g_m_interval(x, z) and g_m_interval(z, y). The limit is the eventual stable value once no more points are inserted between x and y.
- [ ] **Prove g_content_chain_property from C2+C3**: For x < y in limit_dom, chain through adjacent pairs: g_content(f(x)) subset g_interval(x, x1) (by C2) implies phi in g_interval(x, x1) for all phi with G(phi) in f(x). Then temp_4 gives G(phi) in g_interval(x, x1) hence G(phi) in f(x1) (from C3 consequence). Induct through all intermediate points to reach f(y).
- [ ] **Close limit_backward_H**: Follows from g_content_chain_property via the sorry-free duality bridge (g_content_sub_imp_h_content_sub from Phase 1 handoff).
- [ ] **Verify all existing sorry-free lemmas still compile**: limit_c1_at_domain, limit_F_resolution, limit_P_resolution, limit_c3 must remain sorry-free after the restructuring.
- [ ] Run `lake build` and verify

**Timing**: 30 hours

**Depends on**: Phase 0

**Files to modify**:
- `Chronicle/ChronicleTypes.lean` -- add binary g_interval to Chronicle structure, add C2/C3 to ChronicleProperty
- `Chronicle/CounterexampleElimination.lean` -- modify all four elimination functions to return updated g_interval, implement g-splitting for C4/C4'
- `Chronicle/ChronicleConstruction.lean` -- close g_content_chain_property and limit_backward_H (2 sorry sites), redefine limit_g from binary g
- `Chronicle/PointInsertion.lean` -- possibly extend to return g_interval values for new adjacent pairs

**Verification**:
- `lake build` succeeds
- g_content_chain_property is sorry-free
- limit_backward_H is sorry-free
- C2 and C3 are maintained through all omega-chain steps
- limit_g is correctly defined from the binary g construction
- Sorry count: 13 -> 11

---

### Phase 2: Resolve Guard Convention Mismatch (BX9 Bridge) [NOT STARTED]

**Goal**: Prove that the chronicle's open-guard C5 (x < z < y) combined with BX9 (phi U psi -> phi or psi) suffices for the half-open [t, s) guard required by truth semantics.

**Tasks**:
- [ ] **Formalize until_elim_mcs**: BX9 gives (phi U psi) -> (phi or psi). At MCS level: if (phi U psi) in f(x), then phi in f(x) or psi in f(x) (by MCS maximality and disjunction completeness).
- [ ] **Prove half-open guard from open guard**: Given C5 open guard (forall z in dom with x < z < y, guard_formula in f(z)) plus until_elim_mcs (phi in f(x) or psi in f(x)), derive the half-open guard (forall z in dom with x <= z < y, phi in f(z)). Case split: if psi in f(x), the witness is at x and guard interval is empty. If phi in f(x), then x satisfies the guard, and open interval (x, y) is covered by C5.
- [ ] **Strengthen limit_satisfies_c5_weak or add companion lemma**: Add a lemma deriving the half-open guard from existing C5_weak witness plus BX9.
- [ ] **Handle Since direction (C5')**: Mirror the BX9 argument for Since using BX9' (since_elim). The half-open guard for Since is (s, t] which requires the guard at t.
- [ ] Run `lake build` and verify

**Timing**: 8 hours

**Depends on**: Phase 1 (g_content chain needed for guard propagation at intermediate points)

**Files to modify**:
- `Chronicle/ChronicleToCountermodel.lean` -- add BX9-based guard resolution lemmas
- `Chronicle/ChronicleConstruction.lean` -- possibly strengthen C5 limit proofs

**Verification**:
- `lake build` succeeds
- until_elim_mcs proved
- Half-open guard derivation from open guard + BX9 proved
- Clear bridge between C5 (open) and truth semantics (half-open)

---

### Phase 3: Close C4 Sub-Cases and CounterexampleElimination Sorries [NOT STARTED]

**Goal**: Close the 2 remaining sorry sites in CounterexampleElimination.lean (C4 sub-case 1a and C4' sub-case 1a). With the binary g from Phase 1, the g-function infrastructure may provide new proof routes.

**Tasks**:
- [ ] **Paper-validate C4 sub-case 1a**: Given neg(gamma U delta) in f(x) and delta in f(x) and delta in f(y) with x < y adjacent in dom. Need to find z between x and y with neg-delta in f(z). With binary g from Phase 1: g_interval(x, y) satisfies C2, and neg(gamma U delta) in f(x) constrains what can be in g_interval(x, y). Paper-prove or disprove before investing in Lean.
- [ ] **Prove or restructure C4 sub-case 1a**: If paper argument succeeds, formalize. If false, restructure: prove the sub-case cannot arise given C2/C3 invariants, or route through a different C4 elimination strategy that uses the binary g structure.
- [ ] **Close C4' sub-case 1a**: Mirror of the above.
- [ ] Run `lake build` and verify

**Timing**: 12 hours

**Depends on**: Phase 1 (binary g invariant needed for C4 argument)

**Files to modify**:
- `Chronicle/CounterexampleElimination.lean` -- close 2 sorry sites

**Verification**:
- `lake build` succeeds
- CounterexampleElimination.lean is sorry-free
- Sorry count: 11 -> 9

---

### Phase 4: Rat Completeness Milestone -- Replace extended_limit_f, Close 9 Sorry Sites [NOT STARTED]

**Goal**: Replace the provably-false extended_limit_f with a correct construction and close all 9 sorry sites in ChronicleToCountermodel.lean. This achieves the Rat-based representation theorem (Path B milestone matching the ROADMAP goal).

**Tasks**:
- [ ] **Design extended_limit_f replacement**: Evaluate options:
  - (a) Subtype FMCS over {q : Rat // q in limit_dom} with order embedding
  - (b) Nearest-domain-point interpolation for non-domain rationals
  - (c) Accept Path B as D=Rat with GGp->Gp valid for the specific frame class
  Choose the simplest option achieving sorry-free forward_G.
- [ ] **Implement the chosen extended_limit_f replacement**: Modify ChronicleToCountermodel.lean with the new definition.
- [ ] **Prove forward_G**: For domain points: follows from g_content_chain_property (Phase 1). For non-domain points: depends on chosen strategy.
- [ ] **Prove backward_H**: Mirror of forward_G using h_content chain and duality bridge.
- [ ] **Prove box_stable**: All chronicle MCS are box-equivalent to root A by construction (PointInsertion preserves modal content). Prove: Box(phi) in A iff Box(phi) in limit_f(x) for all x.
- [ ] **Prove restricted_tc F**: Use limit_F_resolution (sorry-free) to extract witness, transfer to shifted FMCS coordinates.
- [ ] **Prove restricted_tc P**: Mirror using limit_P_resolution.
- [ ] **Prove restricted_buc Until**: Backward Until coherence. Given U(gamma,delta) NOT in chronicle_fmcs(t) but guard and witness exist, derive contradiction via C4.
- [ ] **Prove restricted_buc Since**: Mirror using C4'.
- [ ] **Prove restricted_fuc Until**: Forward Until coherence. Given U(gamma,delta) in chronicle_fmcs(t), use C5 with Phase 2 BX9 bridge to extract witness.
- [ ] **Prove restricted_fuc Since**: Mirror using C5'.
- [ ] Run `lake build` and verify

**Timing**: 25 hours

**Depends on**: Phases 2, 3 (guard resolution and sorry-free CounterexampleElimination)

**Files to modify**:
- `Chronicle/ChronicleToCountermodel.lean` -- replace extended_limit_f, close all 9 sorry sites

**Verification**:
- `lake build` succeeds
- ChronicleToCountermodel.lean is sorry-free
- `dd_countermodel_chronicle` compiles sorry-free
- `#print axioms dd_countermodel_chronicle` shows no sorryAx
- Sorry count: 9 -> 0
- **Milestone**: Representation theorem achieved (completeness for TaskFrames over totally ordered abelian groups)

---

### Phase 5: Direct BFMCS Truth Lemma over Sparse X (General Completeness) [NOT STARTED]

**Goal**: Build a direct truth lemma for the chronicle model over sparse X = limit_dom, bypassing TaskFrame and AddCommGroup entirely. This gives completeness for ALL strict linear orders, extending beyond the ROADMAP's stated goal.

**Tasks**:
- [ ] **Define ChronicleLinearOrder**: The strict linear order (X, <) where X = limit_dom. Prove it carries LinearOrder (inherited from Rat restriction). Prove it is a strict linear order without endpoints (using seriality: limit_F_resolution gives a future point, limit_P_resolution gives a past point).
- [ ] **Define truth_at_chronicle**: Semantic truth evaluation over the sparse domain X with BFMCS family:
  - Atoms: p true at x iff p in limit_f(x)
  - Boolean: standard
  - G(phi) at x: forall y in X with x < y, phi at y
  - H(phi) at x: forall y in X with y < x, phi at y
  - Until(gamma, delta) at x: exists y in X with x < y, delta at y, forall z in X with x <= z < y, gamma at z (half-open, using Phase 2 BX9 bridge)
  - Since(gamma, delta) at x: mirror
  - Box(phi) at x: forall family members, phi at x in that member
- [ ] **Prove the direct truth lemma (Burgess Claim 2.11)**: For each formula alpha and x in X: alpha in limit_f(x) iff truth_at_chronicle(alpha, x). By induction on alpha:
  - Atom, Bot, Imp: standard MCS properties
  - G: forward uses g_content_chain_property. Backward: contrapositive via F-resolution.
  - H: mirror of G
  - Until: forward uses C5 + BX9 bridge. Backward uses C4 contraposition.
  - Since: mirror of Until
  - Box: forward uses box_stable. Backward uses BFMCS diamond-witness construction.
- [ ] **State and prove bx_completeness_general**: If phi is valid on all strict linear orders, then phi is derivable in BX. Contrapositive: if phi is not derivable, build chronicle with root MCS containing neg phi, sparse X is a strict linear order, truth lemma gives neg phi true at root.
- [ ] **Wire to existing infrastructure**: Add bx_completeness_general alongside existing bx_completeness in Completeness.lean.
- [ ] Run `lake build` and verify

**Timing**: 25 hours

**Depends on**: Phase 4 (box_stable infrastructure, g_content chains, guard conventions)

**Files to modify**:
- New file: `Chronicle/DirectTruthLemma.lean` (~500-700 lines)
- `Metalogic/BXCanonical/Completeness.lean` -- add `bx_completeness_general`

**Verification**:
- `lake build` succeeds
- truth_at_chronicle type-checks and compiles
- Direct truth lemma proved for all formula cases
- `bx_completeness_general` proved sorry-free
- `#print axioms bx_completeness_general` shows no sorryAx
- GGp->Gp is NOT validated (X may be discrete -- correct for BX without density axiom)
- No regression in existing sorry-free modules

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary (6 checkpoints including Phase 0)
- [ ] Phase 0: ROADMAP.md updated, consistent with codebase state
- [ ] Phase 1: g_content_chain_property sorry-free via binary g + C2/C3, sorry count 13 -> 11
- [ ] Phase 2: BX9 guard bridge proved, half-open guard derivable from open guard
- [ ] Phase 3: CounterexampleElimination.lean sorry-free, sorry count 11 -> 9
- [ ] Phase 4: ChronicleToCountermodel.lean sorry-free, `#print axioms dd_countermodel_chronicle` clean, sorry count 9 -> 0
- [ ] Phase 5: DirectTruthLemma.lean compiles, `bx_completeness_general` proved
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] Each paper-proof step validated before Lean formalization (given 4/4 false lemma rate)

## Artifacts & Outputs

- `specs/107_.../plans/17_implementation-plan.md` (this file)
- Modified: `specs/ROADMAP.md` (Phase 0)
- Modified: `Chronicle/ChronicleTypes.lean` (binary g_interval, C2/C3 in ChronicleProperty)
- Modified: `Chronicle/CounterexampleElimination.lean` (g-splitting for C4/C4', close 2 sorries)
- Modified: `Chronicle/ChronicleConstruction.lean` (close 2 sorries: g_content_chain_property, limit_backward_H; redefine limit_g)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (replace extended_limit_f, close 9 sorries)
- Modified: `Chronicle/PointInsertion.lean` (possibly extend for g_interval values)
- New: `Chronicle/DirectTruthLemma.lean` (Path A: direct truth lemma over sparse X)
- Modified: `Completeness.lean` (wire bx_completeness_general)

## Rollback/Contingency

- **Git safety**: The `irr_until` branch preserves the current state. All changes can be reverted to the latest commit (68b8d0d2f).
- **Phase 1 contingency**: If binary g type design proves too complex to integrate with existing infrastructure, consider an intermediate approach: define g as a Map on ordered pairs (using Lean's HashMap or a custom structure), deferring the adjacency-tracking subtype to a later refactoring.
- **Phase 1 alternative**: If g-splitting for C4 insertion is mathematically blocked (the split may not preserve C2/C3 in all cases), fall back to a "rebuild from scratch" strategy at each C4 step: recompute all g_interval values from the updated f assignment rather than splitting incrementally. This is less efficient but mathematically simpler.
- **Phase 3 contingency**: If C4 sub-case 1a is provably false, restructure C4 elimination to prove the sub-case cannot arise given C2/C3 invariants, or weaken the C4 condition to exclude this sub-case.
- **Phase 4 contingency**: If extended_limit_f replacement is too invasive, accept Path B as D=Rat completeness for the specific frame class of totally ordered abelian groups (matching the ROADMAP goal). General completeness comes from Phase 5 only.
- **Phase 5 contingency**: If Box case blocks (BFMCS family without time_shift), ship Path B as the result. The Rat-based representation theorem is independently valuable and matches the stated ROADMAP goal.
- **Budget overrun**: Phases are independently valuable. Even partial completion (Phase 0 + Phase 1 only = updated ROADMAP + binary g infrastructure with g_content chain property) represents significant progress.
