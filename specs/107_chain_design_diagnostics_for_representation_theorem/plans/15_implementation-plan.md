# Implementation Plan: Task #107 (v5 -- Infrastructure-First Rebuild)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 55 hours
- **Dependencies**: None (irr_until branch)
- **Research Inputs**: [reports/10_team-research.md], [reports/11_team-research.md], [reports/12_taskframe-refactoring-scope.md], [reports/13_team-research.md], [reports/14_team-research.md], [reports/15_team-research.md]
- **Artifacts**: plans/15_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: false

## Overview

This plan addresses three layers of infrastructure gaps in the chronicle construction, identified across six rounds of team research. Layer 1 (deepest): the omega-chain's interval function g remains `fun _ _ => ∅` and is never updated, making C3 vacuous and forward_G foundationless. Layer 2: the chronicle's C5 uses open guard (x < z < y) while truth semantics require half-open [t, s), and limit_satisfies_c5_weak provides no guard at all. Layer 3 (shallowest): constructing over D=Rat with forward_G over all rationals automatically validates GGp->Gp, which is not derivable in BX, making the current Rat-based approach incomplete for general completeness.

The plan pursues a two-track strategy: first close the Rat-based pathway (Path B) as a concrete milestone by fixing g-function infrastructure, resolving guard conventions, and closing the 11 remaining sorry sites. Then build a direct BFMCS truth lemma over sparse X (Path A) for general completeness over all strict linear orders. Path B is prerequisite infrastructure for Path A since the g-function and guard fixes are shared.

### Research Integration

- **Report 10** (team): Dense domain recommended. **SUPERSEDED by report 11.**
- **Report 11** (team): Dense domain WRONG for general completeness. GGp->Gp valid on Q but not derivable in BX. Burgess uses sparse X subset Q.
- **Report 12** (scoping): TaskFrame AddCommGroup refactoring is 15-25 days, breaks 3000 lines of sorry-free code. NOT recommended. AddCommGroup is mathematically correct per JPL paper.
- **Report 13** (team): Order-isomorphism NOT viable (doesn't preserve addition). Direct truth lemma over sparse X is the correct approach for general completeness.
- **Report 14** (team): Box case blocks pure single-timeline truth lemma (needs BFMCS for S5 modal saturation). Two viable paths: Path A (direct BFMCS truth lemma over X) and Path B (Rat-based milestone).
- **Report 15** (team): CRITICAL -- g function is trivial (never updated), guard convention mismatch, three-layer problem identified. Infrastructure must be fixed before any domain strategy works.

### Prior Plan Reference

Plan v4 (09_implementation-plan.md) structured work as 8 phases with Phases 1-3 completed and Phase 4 partially completed. Key lessons: (1) false lemma discovery rate was high (4/4 PointInsertion lemmas false under strict semantics), warranting conservative estimates; (2) phases 1-3 successfully withdrew false code and closed easy sorries; (3) Phase 4 achieved 2/3 C4 sub-cases but the third depends on g-function infrastructure that doesn't exist yet; (4) Phase 5 partial -- c5_weak and c5'_weak proved but these are "weak" (no guard); (5) Phase 6 (domain extension) was designed around dense domain, which is now known to be wrong for general completeness. The v4 plan did not account for the g-function being trivial or the guard convention mismatch.

### Roadmap Alignment

- Advances: BX completeness critical path (5 sorry sites in RootScopedChain.lean are bypassed by the chronicle pathway)
- The chronicle pathway in ChronicleToCountermodel.lean replaces the blocked RootScopedChain.lean approach

## Goals & Non-Goals

**Goals**:
- Fix the g-function infrastructure so the interval function is non-trivial through the omega-chain
- Resolve guard convention mismatch between C5 (open) and truth semantics (half-open)
- Close all 11 remaining sorry sites in the chronicle pathway (2 in CounterexampleElimination, 9 in ChronicleToCountermodel)
- Achieve sorry-free `dd_countermodel_chronicle` via the Rat-based pathway (Path B milestone)
- Build a direct BFMCS truth lemma over sparse X for general completeness (Path A)
- Maintain `lake build` success at each phase boundary

**Non-Goals**:
- Refactoring TaskFrame to remove AddCommGroup (report 12 shows this is 15-25 days and breaks 3000 lines)
- Making the chronicle domain dense (report 11 shows this validates GGp->Gp)
- Proving decidability/FMP results (separate concern)
- Modifying the axiom system or adding density axioms
- Fixing sorry sites outside the Chronicle/ directory

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| g-function initialization/update is mathematically harder than expected (R-relation decomposition unproven) | H | M | Start with paper validation of g-splitting. The Int chain's g_content propagation is sorry-free and provides a template. Fall back to simpler g tracking if full decomposition is blocked. |
| C4 sub-case 1a (delta in both endpoints) is a false lemma | H | M | Paper-validate before investing proof effort. If false, restructure C4 elimination to avoid this case (route through g-function + C3 instead). Pattern of 4/4 false PointInsertion lemmas warrants caution. |
| Guard convention mismatch cannot be resolved by BX9 alone | M | M | Study whether the half-open guard at the starting point is derivable from BX9 (phi U psi -> phi or psi). If BX9 gives only a disjunction, may need to strengthen C5 to half-open guard or add a separate starting-point lemma. |
| Path A (direct BFMCS truth lemma) Until/Since cases depend on fixed C5 infrastructure | M | L | Path A is sequenced after Path B, which fixes C5. If Path B stalls, Path A is also blocked for Until/Since but can still make progress on G/H/Box cases. |
| Forward_G over all rationals (Path B) requires extended_limit_f fix that is mathematically non-trivial | H | M | The Rat-based pathway accepts GGp->Gp validity as a consequence. Forward_G for non-domain rationals follows from the MCS assignment rule (e.g., nearest-domain-point or g_content-based extension). If this is blocked, scope Path B to domain-points-only forward_G and defer full Rat coverage. |
| Discovery of additional false lemmas during implementation | M | H | Budget 30% buffer in estimates. Test claims with paper proofs or Lean counterexamples before investing in long proofs. |

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

### Phase 1: Fix g-Function Infrastructure (Layer 1) [PARTIAL]

**Goal**: Make the chronicle's interval function g non-trivial by defining how g is initialized during point insertion, updated through the omega-chain, and carried to the limit. This is the deepest infrastructure gap and prerequisite for everything downstream.

**Tasks**:
- [ ] **Audit current g usage**: Read ChronicleTypes.lean to understand the g field type signature and C3 condition. Verify that singleton_chronicle sets g = fun _ _ => emptyset. Trace how omega_chain_step handles g during counterexample elimination.
- [ ] **Design g initialization for point insertion**: When inserting z between x and y via lemma_2_4 or lemma_2_6, define g(x,z) and g(z,y) from the R-relation decomposition. The key property: if R(f(x), delta, f(y)) holds, then inserting z with f(z) constructed from g_content(f(x)) should give R(f(x), delta1, f(z)) and R(f(z), delta2, f(y)) for appropriate delta1, delta2.
- [ ] **Implement g update in counterexample elimination**: Modify eliminate_C4_counterexample and eliminate_C5_counterexample (and their primed variants) to return updated g values alongside the new f and dom. Each insertion must set g(x,z) = {formulas witnessed between x and z} and g(z,y) = {formulas witnessed between z and y}.
- [ ] **Prove C3 preservation**: After each insertion step, verify g_content(f(x)) subset g(x,z) and g_content(f(z)) subset g(z,y). This follows from the construction: f(z) is a Lindenbaum extension of g_content(f(x)), so g_content(f(x)) subset f(z), and the g assignment captures this.
- [ ] **Define limit_g**: Analogous to limit_f, define limit_g(x,y) as the g-value from the stage where both x and y first appear in the domain. Prove consistency: if both x and y are in stage n, then g_n(x,y) = g_m(x,y) for all m >= n.
- [ ] **Prove limit chronicle satisfies C3**: g_content(limit_f(x)) subset limit_g(x,y) for adjacent domain points x < y.
- [ ] Run `lake build` and verify

**Timing**: 12 hours

**Depends on**: none

**Files to modify**:
- `Chronicle/ChronicleTypes.lean` -- possibly adjust g field or add helper definitions
- `Chronicle/CounterexampleElimination.lean` -- update elimination functions to maintain g
- `Chronicle/ChronicleConstruction.lean` -- add limit_g definition and C3 limit proof
- `Chronicle/PointInsertion.lean` -- add g-initialization lemmas for point insertion

**Verification**:
- `lake build` succeeds
- limit_g is defined and type-checks
- C3 limit proof compiles (may have targeted sorries for R-relation decomposition details)
- The g function is no longer trivially empty after the first point insertion

---

### Phase 2: Resolve Guard Convention Mismatch (Layer 2) [NOT STARTED]

**Goal**: Align the chronicle's C5 condition with the half-open [t, s) guard convention used by truth semantics, or prove that the current open-guard C5 plus BX9 suffices.

**Tasks**:
- [ ] **Document the exact mismatch**: Write down the truth semantic requirement for Until: exists s > t with psi(s) and forall r with t <= r < s, phi(r). The chronicle C5 provides: exists y > x in dom with eta in f(y) and forall z in dom with x < z < y, xi in f(z). The gap is the guard at x itself (t <= r includes t; x < z excludes x).
- [ ] **Analyze BX9 resolution**: BX9 gives (phi U psi) -> (phi or psi). If phi U psi in f(x), then phi in f(x) or psi in f(x). If psi in f(x), the witness is x itself and the guard interval is empty. If phi in f(x), the guard at x is satisfied. Formalize this argument in Lean.
- [ ] **Strengthen C5 if BX9 is insufficient**: If the BX9 argument has gaps (e.g., the guard at x requires phi, not just phi-or-psi), modify the chronicle's C5 to use half-open guard: forall z in dom with x <= z < y, xi in f(z). This requires re-proving limit_satisfies_c5_weak with the stronger condition.
- [ ] **Verify C5_weak is sufficient or strengthen it**: The current limit_satisfies_c5_weak provides only witness existence (no guard). Determine whether the full guard (open or half-open) is needed at the limit, or whether BX9 + MCS properties suffice to reconstruct guards from witnesses.
- [ ] Run `lake build` and verify

**Timing**: 6 hours

**Depends on**: Phase 1 (g-function infrastructure needed for guard propagation at intermediate points via C3)

**Files to modify**:
- `Chronicle/ChronicleTypes.lean` -- possibly strengthen C5 definition
- `Chronicle/ChronicleConstruction.lean` -- re-prove or strengthen limit_satisfies_c5_weak
- `Chronicle/ChronicleToCountermodel.lean` -- add BX9-based guard resolution lemma

**Verification**:
- `lake build` succeeds
- Either: BX9 resolution lemma proved (showing open guard + BX9 => half-open guard), OR C5 strengthened to half-open with limit proof updated
- Clear documentation of which guard convention the chronicle uses and why it suffices

---

### Phase 3: Close C4 Sub-Case 1a and Remaining CounterexampleElimination Sorries [NOT STARTED]

**Goal**: Close the 2 remaining sorry sites in CounterexampleElimination.lean (C4 sub-case 1a where delta is in both f(x) and f(y), and its C4' mirror). These were deferred from plan v4 Phase 4 because they require g-function infrastructure from Phase 1.

**Tasks**:
- [ ] **Paper-validate C4 sub-case 1a**: Before investing proof effort, construct a pencil-and-paper argument or Lean counterexample for: given delta in f(x) and delta in f(y) with neg(gamma U delta) in f(x), and x < y adjacent in dom, can we always find z between x and y with neg-delta in f(z)? Use the g-function (now non-trivial from Phase 1) and C3 to trace the argument.
- [ ] **Prove or restructure C4 sub-case 1a** (line 289): If the paper argument succeeds, formalize it using g_content(f(x)) subset g(x,y) from C3 and the R-relation structure. If the claim is false, restructure C4 elimination to handle this case differently (e.g., show the sub-case cannot arise given the chronicle invariants, or route through a different point insertion strategy).
- [ ] **Close C4' sub-case 1a** (line 355): Mirror of the above.
- [ ] Run `lake build` and verify

**Timing**: 8 hours

**Depends on**: Phase 1 (g-function must be non-trivial for C3-based argument)

**Files to modify**:
- `Chronicle/CounterexampleElimination.lean` -- close 2 sorry sites (lines 289, 355)

**Verification**:
- `lake build` succeeds
- CounterexampleElimination.lean is sorry-free
- Sorry count: 11 -> 9

---

### Phase 4: Close ChronicleToCountermodel Sorry Sites (Path B -- Rat Milestone) [NOT STARTED]

**Goal**: Close all 9 sorry sites in ChronicleToCountermodel.lean using the fixed g-function infrastructure (Phase 1), resolved guard conventions (Phase 2), and sorry-free CounterexampleElimination (Phase 3). This completes the Rat-based completeness pathway.

**Tasks**:
- [ ] **Fix extended_limit_f**: The current design assigns root MCS A to non-domain rationals, which makes forward_G unprovable under strict semantics. Replace with a g_content-based extension: for non-domain rational r, find the nearest domain points x < r < y (or r < x_min or r > x_max) and assign mcs(r) based on g_content interpolation from f(x) and f(y). Alternatively, use a constant-extension rule where mcs(r) = f(nearest_domain_point).
- [ ] **Prove forward_G** (line 192): For s < t in Rat, G(phi) in mcs(s) -> phi in mcs(t). Split into cases: (a) both s,t in domain -- use g_content chain via C3 and limit_g; (b) s or t not in domain -- use the extended_limit_f assignment rule to reduce to case (a).
- [ ] **Prove backward_H** (line 196): Mirror of forward_G using h_content and C2'.
- [ ] **Prove box_stable** (line 234): Box(phi) in chronicle_fmcs(t) iff Box(phi) in A. Uses forward_G + backward_H: Box(phi) -> G(Box(phi)) by BX temporal axiom, so Box(phi) propagates forward. All chronicle MCS are box-equivalent to A by construction (chronicle preserves modal content).
- [ ] **Prove restricted_tc F** (line 320): F(phi) in shifted_chronicle at t. Extract witness from C5 (now with guard from Phase 2). Transfer to shifted FMCS coordinates.
- [ ] **Prove restricted_tc P** (line 323): Mirror using C5' for Past.
- [ ] **Prove restricted_buc Until** (line 342): Given Until-witness pattern, derive Until membership via C4 contraposition. If neg(gamma U delta) in f(t), C4 gives z between t and witness with neg-delta in f(z), contradicting guard.
- [ ] **Prove restricted_buc Since** (line 345): Mirror using C4'.
- [ ] **Prove restricted_fuc Until** (line 374): Until(gamma, delta) in shifted_chronicle at t. By C5 of limit chronicle, extract witness with guard at intermediate domain points. With Phase 2 guard resolution, extend to half-open semantics. Transfer to shifted FMCS.
- [ ] **Prove restricted_fuc Since** (line 377): Mirror using C5'.
- [ ] Run `lake build` and verify

**Timing**: 16 hours

**Depends on**: Phases 2, 3 (guard resolution and sorry-free CounterexampleElimination both needed)

**Files to modify**:
- `Chronicle/ChronicleToCountermodel.lean` -- fix extended_limit_f, close all 9 sorry sites

**Verification**:
- `lake build` succeeds
- ChronicleToCountermodel.lean is sorry-free
- `dd_countermodel_chronicle` compiles sorry-free
- `#print axioms dd_countermodel_chronicle` shows no sorryAx
- Sorry count: 9 -> 0
- **Milestone**: Rat-based completeness pathway is complete (completeness for ordered-group TaskFrame models)

---

### Phase 5: Direct BFMCS Truth Lemma over Sparse X (Path A -- General Completeness) [NOT STARTED]

**Goal**: Build a direct truth lemma for the chronicle model (X, <, V) with BFMCS family structure, bypassing TaskFrame and AddCommGroup entirely. This gives completeness for ALL strict linear orders, not just dense ordered-group frames.

**Tasks**:
- [ ] **Define `ChronicleLinearOrder`**: The strict linear order (X, <) where X = limit_dom. Prove it carries LinearOrder (inherited from Rat restriction).
- [ ] **Define `truth_at_chronicle_bfmcs`**: Semantic truth evaluation over the sparse domain X with BFMCS family:
  - Atoms: p true at x iff p in limit_f(x)
  - Boolean: standard
  - G(phi) at x: forall y in X with x < y, phi at y
  - H(phi) at x: forall y in X with y < x, phi at y
  - Until(gamma, delta) at x: exists y in X with x < y, delta at y, forall z in X with x <= z < y, gamma at z
  - Since(gamma, delta) at x: mirror
  - Box(phi) at x: forall family members f_i, phi at x in f_i
- [ ] **Prove the direct truth lemma (Claim 2.11)**: For each formula alpha and x in X: alpha in limit_f(x) <-> truth_at_chronicle_bfmcs(alpha, x). By induction on alpha:
  - Atom, Bot, Imp: standard MCS properties
  - G: forward direction uses g_content chain (Phase 1 infrastructure). Backward uses C5 witness extraction.
  - H: mirror of G
  - Until: forward uses C5 (with guard from Phase 2). Backward uses C4 contraposition.
  - Since: mirror of Until
  - Box: forward uses box_stable (chronicle family members share modal content). Backward uses BFMCS diamond-witness construction. THIS IS THE KEY CASE: no time_shift needed because family members are evaluated at the SAME domain point via the family's own MCS assignment, not via shifted timelines.
- [ ] **State `bx_completeness_general`**: If phi is valid on all strict linear orders, then phi is derivable in BX. The countermodel for non-derivable phi is (X, <, V) which is a strict linear order (not necessarily dense or discrete), so phi fails at the root.
- [ ] **Wire completeness**: Connect `bx_completeness_general` to the existing infrastructure. The combined result: derivable in BX <-> valid on all strict linear orders.
- [ ] Run `lake build` and verify

**Timing**: 13 hours

**Depends on**: Phase 4 (Path B infrastructure -- g-function, guard conventions, and BFMCS family construction are all reused)

**Files to modify**:
- New file: `Chronicle/DirectTruthLemma.lean` (~400-600 lines) -- sparse-X truth evaluation and truth lemma
- `Metalogic/BXCanonical/Completeness.lean` -- add `bx_completeness_general` theorem

**Verification**:
- `lake build` succeeds
- `truth_at_chronicle_bfmcs` type-checks
- Direct truth lemma compiles (may have targeted sorries for difficult cases)
- `bx_completeness_general` stated and wired
- No modification to any existing sorry-free code
- GGp->Gp is NOT validated by this pathway (X may be discrete)

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary (5 checkpoints)
- [ ] Phase 1: limit_g defined, C3 at limit proved, g non-trivial after first insertion
- [ ] Phase 2: Guard convention resolved (BX9 lemma or strengthened C5)
- [ ] Phase 3: CounterexampleElimination.lean sorry-free
- [ ] Phase 4: ChronicleToCountermodel.lean sorry-free; `#print axioms dd_countermodel_chronicle` shows no sorryAx
- [ ] Phase 5: DirectTruthLemma.lean compiles; `bx_completeness_general` stated
- [ ] No regression in existing sorry-free modules (Soundness.lean, Decidability/FMP, ParametricTruthLemma)

## Artifacts & Outputs

- `specs/107_.../plans/15_implementation-plan.md` (this file)
- Modified: `Chronicle/ChronicleTypes.lean` (g-function infrastructure)
- Modified: `Chronicle/PointInsertion.lean` (g-initialization lemmas)
- Modified: `Chronicle/CounterexampleElimination.lean` (g-update, close 2 sorries)
- Modified: `Chronicle/ChronicleConstruction.lean` (limit_g, C3 limit, guard strengthening)
- Modified: `Chronicle/ChronicleToCountermodel.lean` (fix extended_limit_f, close 9 sorries)
- New: `Chronicle/DirectTruthLemma.lean` (Path A -- direct BFMCS truth lemma over sparse X)
- Modified: `Completeness.lean` (wire bx_completeness_general)

## Rollback/Contingency

- **Git safety**: The `irr_until` branch preserves the current state. All changes can be reverted to the latest commit.
- **Phase 1 contingency**: If R-relation decomposition for g-splitting is blocked, implement a simpler g-tracking that records only the formulas explicitly inserted (not the full R-relation decomposition). This may be sufficient for the forward_G chain even if it doesn't give the full C3 guarantee.
- **Phase 3 contingency**: If C4 sub-case 1a is provably false, restructure C4 elimination to bypass the sub-case entirely (e.g., prove the sub-case cannot arise given chronicle invariants, or use a different insertion strategy that avoids the problematic configuration).
- **Phase 4 contingency**: If extended_limit_f fix is blocked, scope the milestone to "forward_G for domain points only" and defer full-Rat coverage. The direct truth lemma (Phase 5) doesn't need full-Rat forward_G.
- **Phase 5 contingency**: If the Box case of the direct truth lemma is blocked (BFMCS family construction without time_shift), defer Phase 5 and ship Path B (Rat-based completeness) as the interim result. Path A can be pursued in a follow-up task.
- **Incremental progress**: Each phase reduces sorry count or adds new infrastructure independently. Even partial completion represents genuine progress.
