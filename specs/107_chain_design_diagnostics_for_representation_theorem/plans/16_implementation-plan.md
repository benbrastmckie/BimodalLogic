# Implementation Plan: Task #107 (v6 -- Chronicle Rebuild with Correct g-Function)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 100 hours
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/11_team-research.md], [reports/15_team-research.md], [reports/16_team-research.md]
- **Artifacts**: plans/16_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan rebuilds the chronicle construction around a properly maintained g-function and corrected guard conventions. Plan v5 Phase 1 revealed two critical findings: (1) extended_limit_f makes forward_G provably FALSE (not just unproven) because it assigns root MCS A to non-domain rationals, requiring Gp->p which is invalid under strict semantics; (2) g_content_chain_property requires modified elimination seeds to include g_content of ALL predecessors, not just the immediate one. The plan preserves all sorry-free progress from v5 Phase 1 (limit_g, limit_F/P_resolution, limit_c3) and rebuilds around these findings.

The plan has two tracks. Track 1 (Phases 1-4) fixes the chronicle infrastructure and closes the 14 remaining sorry sites to achieve a sorry-free `dd_countermodel_chronicle` over the sparse domain X (the representation theorem: TM is complete w.r.t. TaskFrames over totally ordered abelian groups, per ROADMAP). Track 2 (Phase 5) builds a direct truth lemma over sparse X for general completeness over all strict linear orders. The 100-hour budget reflects the false-lemma discovery rate (4/4 PointInsertion lemmas were false in earlier plans) and the non-trivial g_content_chain_property bottleneck.

### Research Integration

- **Report 11** (density analysis): Dense domain WRONG for general completeness. GGp->Gp valid on Q but not derivable in BX. Burgess uses sparse X subset Q. Reversed report 10's recommendation.
- **Report 15** (infrastructure gaps): Three-layer problem identified. Layer 1: g function trivial (never updated). Layer 2: C5 open guard vs half-open semantics. Layer 3: domain extension/density. All layers must be fixed before domain strategy matters.
- **Report 16** (critical evaluation): Chronicle IS the right path. Escapes Lindenbaum opacity via controlled PointInsertion. All gaps are engineering, not mathematical impossibilities. Hybrid Int-chain + enriched seed is dead end (#7, #13, #23, #31). Budget 100h given discovery rate.

### Prior Plan Reference

Plan v5 (15_implementation-plan.md) structured work as 5 phases. Phase 1 was partially implemented: limit_g defined, limit_F/P_resolution sorry-free, limit_c3 sorry-free, but g_content_chain_property sorry'd (critical bottleneck). Key lessons: (1) extended_limit_f is provably FALSE for forward_G -- needs complete redesign; (2) g_content_chain_property requires enlarging elimination seeds to carry g_content of all predecessors; (3) the sorry count went from 11 to 14 (3 infrastructure placeholders added). The v5 plan did not account for extended_limit_f being false (assumed it was just unproven). This v6 plan restructures Phase 1 around the g_content_chain_property fix (modifying elimination seeds) and replaces the extended_limit_f strategy entirely.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (ROADMAP representation theorem goal)
- The chronicle pathway in ChronicleToCountermodel.lean replaces the blocked RootScopedChain.lean approach (5 critical-path sorry sites become dead code)
- Phase 5 extends beyond the ROADMAP goal to achieve completeness for all strict linear orders

## Goals & Non-Goals

**Goals**:
- Fix g_content_chain_property by modifying the omega-chain elimination seeds to maintain g_content propagation
- Resolve guard convention mismatch between C5 (open) and truth semantics (half-open) via BX9
- Replace the provably-false extended_limit_f with a correct domain-aware FMCS construction
- Close all 14 remaining sorry sites in the Chronicle/ directory
- Achieve sorry-free `dd_countermodel_chronicle` (Path B: Rat-based representation theorem)
- Build direct BFMCS truth lemma over sparse X for general completeness (Path A)
- Maintain `lake build` success at each phase boundary

**Non-Goals**:
- Refactoring TaskFrame to remove AddCommGroup (15-25 days, breaks 3000 lines of sorry-free code)
- Making the chronicle domain dense (validates GGp->Gp, wrong for general completeness)
- Fixing sorry sites outside the Chronicle/ directory (task 109 scope)
- Modifying the BX axiom system
- Proving decidability/FMP results (separate track)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Enlarged elimination seeds are inconsistent when carrying g_content of all predecessors | H | M | Paper-validate seed consistency before Lean proof. The key risk: G(F(alpha)->neg psi) in some predecessor M could conflict with g_content of M. But PointInsertion seeds use g_content of a SPECIFIC predecessor, not f_carry -- this is different from dead end #13 which mixes f_carry with g_content. |
| C4 sub-case 1a (delta in both endpoints) is a false lemma | H | M | Paper-validate first. If false, restructure C4 elimination to route this case through g-function + C3. Pattern of false lemmas warrants extreme caution. |
| extended_limit_f replacement (domain-aware FMCS) introduces new architectural complexity | M | M | Design two alternatives up front: (a) subtype FMCS over limit_dom with order embedding into Rat, (b) nearest-domain-point interpolation for non-domain rationals. Choose whichever is simpler to prove forward_G for. |
| Path A Box case blocks on BFMCS family construction without time_shift | M | M | Path A is sequenced after Path B. If Box case blocks, ship Path B (Rat-based completeness) as the result and defer Path A to a follow-up task. |
| Discovery of additional false lemmas during implementation | M | H | Budget 30% contingency. Paper-prove claims before investing in Lean formalization. Use MCP lean_verify for quick checks. |
| g_content_chain_property proof is deeper than estimated (requires novel lemma about temp_4 chain propagation) | H | M | temp_4 (Gp->GGp) is the key tool. If direct proof is blocked, try an alternative: prove that the omega-chain construction can be modified to insert intermediate "relay" points that maintain g_content chains by construction. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2, 3 | 1 |
| 3 | 4 | 2, 3 |
| 4 | 5 | 4 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Fix g_content_chain_property via Modified Elimination Seeds [NOT STARTED]

**Goal**: Close the critical bottleneck `g_content_chain_property` (g_content(limit_f(x)) subset limit_f(y) for x < y in limit_dom) by modifying the omega-chain's counterexample elimination functions to maintain g_content propagation as an invariant. Also close `limit_c1_at_domain` and `limit_backward_H`.

**Tasks**:
- [ ] **Paper-validate the enlarged seed approach**: When C5 elimination inserts point z for U(xi,eta) at x with witness y, the current seed for f(z) is g_content(f(x)) union {xi, eta, ...}. The fix: for each predecessor x' < z already in dom, include g_content(f(x')) in the seed for f(z). Verify on paper that this enlarged seed is consistent. Key argument: g_content(f(x')) subset f(x) (by induction, since x' < x and the invariant holds at earlier stages), so g_content(f(x')) is already a subset of the consistent set f(x). The enlarged seed is a subset of f(x) union g_content(f(x)) union {target formulas}, which is consistent by the existing PointInsertion lemma.
- [ ] **Modify eliminate_C5_counterexample**: Change the seed construction to include g_content of all predecessor domain points. This requires passing the current domain and f-assignment as context to the elimination function. Add the g_content_chain invariant as a precondition and postcondition.
- [ ] **Modify eliminate_C5'_counterexample**: Mirror for Since/Past direction.
- [ ] **Modify eliminate_C4_counterexample**: Similarly maintain g_content chain through C4 insertion. When inserting z between x and y for neg(gamma U delta), the seed must maintain g_content(f(x')) subset f(z) for all x' < z.
- [ ] **Modify eliminate_C4'_counterexample**: Mirror.
- [ ] **Prove the omega-chain inductive invariant**: At each stage n of the omega-chain, for all x < y in dom_n, g_content(f_n(x)) subset f_n(y). Base case: singleton domain (vacuous). Inductive step: the modified elimination functions preserve the invariant.
- [ ] **Close g_content_chain_property**: The limit inherits the invariant from all finite stages. For x < y in limit_dom, both appear at some stage n, and g_content(f_n(x)) subset f_n(y) by the inductive invariant. Since limit_f(x) = f_n(x) for sufficiently large n (stabilization), the property transfers.
- [ ] **Close limit_backward_H**: Dual argument using h_content and the backward (y < x) direction of g_content_chain_property. Requires a dual h_content_chain_property.
- [ ] **Close limit_c1_at_domain**: g_content consistency for limit_g. Uses g_content_set_consistent (sorry-free in Frame.lean) applied to the MCS limit_f(x).
- [ ] Run `lake build` and verify

**Timing**: 25 hours

**Depends on**: none

**Files to modify**:
- `Chronicle/CounterexampleElimination.lean` -- modify elimination functions to maintain g_content chain invariant
- `Chronicle/ChronicleConstruction.lean` -- close g_content_chain_property, limit_backward_H, limit_c1_at_domain (3 sorry sites)
- `Chronicle/ChronicleTypes.lean` -- possibly add g_content_chain invariant to ChronicleProperty

**Verification**:
- `lake build` succeeds
- g_content_chain_property is sorry-free
- limit_backward_H is sorry-free
- limit_c1_at_domain is sorry-free
- Sorry count: 14 -> 11

---

### Phase 2: Resolve Guard Convention Mismatch (BX9 Bridge) [NOT STARTED]

**Goal**: Prove that the chronicle's open-guard C5 (x < z < y) combined with BX9 (phi U psi -> phi or psi) suffices for the half-open [t, s) guard required by truth semantics. This resolves Layer 2 of the infrastructure gaps.

**Tasks**:
- [ ] **Formalize until_elim_mcs**: BX9 gives (phi U psi) -> (phi or psi). At MCS level: if (phi U psi) in f(x), then phi in f(x) or psi in f(x) (by MCS maximality and disjunction completeness).
- [ ] **Prove half-open guard from open guard**: Given C5 open guard (forall z in dom with x < z < y, guard_formula in f(z)) plus until_elim_mcs (phi in f(x) or psi in f(x)), derive the half-open guard (forall z in dom with x <= z < y, phi in f(z)). Case split: if psi in f(x), the witness is at x and the guard interval is empty. If phi in f(x), then x satisfies the guard, and the open interval (x, y) is covered by C5.
- [ ] **Strengthen limit_satisfies_c5_weak or add a companion lemma**: limit_satisfies_c5_weak currently provides only witness existence. Either strengthen it to include the half-open guard, or add a separate lemma that derives the guard from the existing C5_weak witness plus BX9. The second approach is likely simpler.
- [ ] **Handle the Since direction (C5')**: Mirror the BX9 argument for Since using BX9' (since_elim). The half-open guard for Since is (s, t] which requires the guard at t.
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

**Goal**: Close the 2 remaining sorry sites in CounterexampleElimination.lean (C4 sub-case 1a at line 289 and C4' sub-case 1a at line 355). These were deferred from plan v4 because they depend on the g-function infrastructure from Phase 1.

**Tasks**:
- [ ] **Paper-validate C4 sub-case 1a**: Given neg(gamma U delta) in f(x) and delta in f(x) and delta in f(y) with x < y adjacent in dom. Need to find z between x and y with neg-delta in f(z). With the fixed g-function from Phase 1: g_content(f(x)) subset f(z) by construction. If neg-delta is derivable from g_content(f(x)), we're done. If not, use the C4 axiom (BX4) to derive the existence of z from the temporal structure. Paper-prove before investing in Lean.
- [ ] **Prove or restructure C4 sub-case 1a** (line 289): If paper argument succeeds, formalize. If the claim is false (possible given 4/4 previous false lemmas), restructure: prove the sub-case cannot arise given the g_content_chain invariant (Phase 1), or route through a different insertion strategy.
- [ ] **Close C4' sub-case 1a** (line 355): Mirror of the above.
- [ ] Run `lake build` and verify

**Timing**: 12 hours

**Depends on**: Phase 1 (g_content chain invariant needed for C4 argument)

**Files to modify**:
- `Chronicle/CounterexampleElimination.lean` -- close 2 sorry sites (lines 289, 355)

**Verification**:
- `lake build` succeeds
- CounterexampleElimination.lean is sorry-free
- Sorry count: 11 -> 9

---

### Phase 4: Replace extended_limit_f and Close ChronicleToCountermodel Sorries [NOT STARTED]

**Goal**: Replace the provably-false extended_limit_f with a correct construction and close all 9 sorry sites in ChronicleToCountermodel.lean. This achieves the Rat-based representation theorem (Path B milestone).

**Tasks**:
- [ ] **Design extended_limit_f replacement**: Two options to evaluate:
  - (a) **Subtype FMCS**: Define the FMCS over the subtype {q : Rat // q in limit_dom} rather than all of Rat. This naturally restricts forward_G/backward_H to domain points only. Requires proving the subtype carries LinearOrder and wiring into the parametric infrastructure. May conflict with AddCommGroup requirement.
  - (b) **Nearest-domain-point interpolation**: For non-domain rational r, assign mcs(r) = limit_f(nearest domain point). forward_G at non-domain points follows from forward_G at domain points plus the fact that nearest-domain-point is monotone. This preserves D=Rat but changes the MCS assignment rule.
  - (c) **Accept Path B as D=Rat with GGp->Gp**: Since the ROADMAP goal is "TaskFrames over totally ordered abelian groups" and Rat IS a totally ordered abelian group where GGp->Gp is valid, accept that Path B gives completeness for this specific frame class. The general-completeness (all strict linear orders) comes from Path A (Phase 5), which doesn't use extended_limit_f at all.
  Choose the simplest option that achieves sorry-free forward_G.
- [ ] **Implement the chosen extended_limit_f replacement**: Modify ChronicleToCountermodel.lean with the new definition and prove it type-checks.
- [ ] **Prove forward_G** (line 192): For domain points: follows from g_content_chain_property (Phase 1). For non-domain points: depends on the chosen strategy above.
- [ ] **Prove backward_H** (line 196): Mirror of forward_G using h_content chain.
- [ ] **Prove box_stable** (line 234): All chronicle MCS are box-equivalent to root A by construction (PointInsertion preserves modal content via modal_future/temp_future axioms). Prove: Box(phi) in A iff Box(phi) in limit_f(x) for all x in limit_dom.
- [ ] **Prove restricted_tc F** (line 320): F(phi) in chronicle_fmcs(t) at shifted position. Use limit_F_resolution (sorry-free from v5 Phase 1) to extract witness, then transfer to shifted FMCS coordinates.
- [ ] **Prove restricted_tc P** (line 323): Mirror using limit_P_resolution.
- [ ] **Prove restricted_buc Until** (line 342): Backward Until coherence. Given U(gamma,delta) NOT in chronicle_fmcs(t) but guard and witness exist, derive contradiction via C4. If neg(gamma U delta) in f(t), C4 gives a point z between t and witness with neg-delta in f(z), contradicting the guard at z.
- [ ] **Prove restricted_buc Since** (line 345): Mirror using C4'.
- [ ] **Prove restricted_fuc Until** (line 374): Forward Until coherence. Given U(gamma,delta) in chronicle_fmcs(t), use C5 with the Phase 2 BX9 bridge to extract witness y with delta in f(y) and half-open guard at all z in [t, y). Transfer to shifted FMCS.
- [ ] **Prove restricted_fuc Since** (line 377): Mirror using C5'.
- [ ] Run `lake build` and verify

**Timing**: 30 hours

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
  - G: forward direction uses g_content_chain_property (Phase 1). Backward: if phi at all y > x, need G(phi) in limit_f(x). Use contrapositive: if G(phi) not in f(x), then neg G(phi) in f(x), so F(neg phi) in f(x), so by limit_F_resolution exists y > x with neg phi in f(y), contradicting phi at y.
  - H: mirror of G
  - Until: forward uses C5 + BX9 bridge (Phase 2). Backward uses C4 contraposition.
  - Since: mirror of Until
  - Box: forward uses box_stable (Phase 4). Backward uses BFMCS diamond-witness construction (box_neg in one family member gives neg_box_neg = diamond in f(x), so diamond(neg phi) in f(x), construct family member where neg phi holds at x).
- [ ] **State and prove bx_completeness_general**: If phi is valid on all strict linear orders, then phi is derivable in BX. Contrapositive: if phi is not derivable, then neg phi is consistent, extend to MCS A, build chronicle with root A, sparse X is a strict linear order, truth lemma gives neg phi true at root, so phi fails on a strict linear order.
- [ ] **Wire to existing infrastructure**: Add bx_completeness_general alongside the existing bx_completeness in Completeness.lean. No modification to existing sorry-free code.
- [ ] Run `lake build` and verify

**Timing**: 25 hours

**Depends on**: Phase 4 (box_stable infrastructure, g_content chains, guard conventions)

**Files to modify**:
- New file: `Chronicle/DirectTruthLemma.lean` (~500-700 lines) -- sparse-X truth evaluation and truth lemma
- `Metalogic/BXCanonical/Completeness.lean` -- add `bx_completeness_general` theorem

**Verification**:
- `lake build` succeeds
- truth_at_chronicle type-checks and compiles
- Direct truth lemma proved for all formula cases
- `bx_completeness_general` proved sorry-free
- `#print axioms bx_completeness_general` shows no sorryAx
- GGp->Gp is NOT validated (X may be discrete -- correct for BX without density axiom)
- No regression in existing sorry-free modules

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary (5 checkpoints)
- [ ] Phase 1: g_content_chain_property sorry-free, sorry count 14 -> 11
- [ ] Phase 2: BX9 guard bridge proved, half-open guard derivable from open guard
- [ ] Phase 3: CounterexampleElimination.lean sorry-free, sorry count 11 -> 9
- [ ] Phase 4: ChronicleToCountermodel.lean sorry-free, `#print axioms dd_countermodel_chronicle` clean, sorry count 9 -> 0
- [ ] Phase 5: DirectTruthLemma.lean compiles, `bx_completeness_general` proved
- [ ] No regression in existing sorry-free modules (Soundness, FMP, ParametricTruthLemma)
- [ ] Each paper-proof step validated before Lean formalization (given 4/4 false lemma rate)

## Artifacts & Outputs

- `specs/107_.../plans/16_implementation-plan.md` (this file)
- Modified: `Chronicle/CounterexampleElimination.lean` (g_content chain invariant, close 2 sorries)
- Modified: `Chronicle/ChronicleConstruction.lean` (close 3 sorries: g_content_chain_property, limit_backward_H, limit_c1_at_domain)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (replace extended_limit_f, close 9 sorries)
- Modified: `Chronicle/ChronicleTypes.lean` (g_content_chain invariant)
- New: `Chronicle/DirectTruthLemma.lean` (Path A: direct truth lemma over sparse X)
- Modified: `Completeness.lean` (wire bx_completeness_general)

## Rollback/Contingency

- **Git safety**: The `irr_until` branch preserves the current state. All changes can be reverted to the latest commit (68b8d0d2f).
- **Phase 1 contingency**: If enlarged elimination seeds are inconsistent, fall back to "relay point" strategy: instead of carrying g_content of all predecessors, insert dedicated relay points between non-adjacent domain points that maintain g_content chains. This adds points but avoids seed enlargement.
- **Phase 3 contingency**: If C4 sub-case 1a is provably false, restructure C4 elimination to prove the sub-case cannot arise (given g_content_chain invariant, delta in f(x) and delta in f(y) may be impossible when neg(gamma U delta) in f(x), because C4 prevents exactly this). Alternatively, weaken the C4 condition to exclude this sub-case.
- **Phase 4 contingency**: If extended_limit_f replacement is too invasive, use option (c): accept Path B as D=Rat completeness for the specific frame class of totally ordered abelian groups (matching the ROADMAP goal). General completeness comes from Phase 5 only.
- **Phase 5 contingency**: If Box case blocks (BFMCS family without time_shift), ship Path B as the result. Path A can be pursued in a follow-up task. The Rat-based representation theorem is independently valuable and matches the stated ROADMAP goal.
- **Budget overrun**: Phases are independently valuable. Even partial completion (Phases 1-3 only = sorry-free CounterexampleElimination + g_content chain infrastructure) represents significant progress.
