# Implementation Plan: Task #153

- **Task**: 153 - prove_succ_cofinal_discrete
- **Status**: [NOT STARTED]
- **Effort**: 6 hours
- **Dependencies**: None (secondary to Reynolds pipeline tasks 154-155)
- **Research Inputs**: specs/153_prove_succ_cofinal_discrete/reports/02_team-research.md
- **Artifacts**: plans/02_succ-cofinal-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Prove `succ_cofinal` at ChronicleToCountermodel.lean:1885 -- the theorem that for any points a < b in the discrete limit domain, there exists n such that succ^[n](a) >= b. The existing proof infrastructure already establishes the contradiction-by-convergence setup (steps 1-8), backward_G, backward_F, backward_P, orbit_below_L, h_lt_pred_chain, and h_pred_chain_ge_L. The sorry sits at step 9 ("gap elimination") where the orbit converges to L from below while the pred-chain descends to L from above, forming a Z+Z-like gap that must be shown contradictory using temporal logic axioms. Team research identified that the constant-MCS case is formally excluded by Prior-UZ + truth lemma, narrowing the problem to the non-constant case where a discriminating formula exists but controlling its truth at all future points remains the core challenge.

### Research Integration

The team research report (4 teammates) produced three key findings integrated into this plan:

1. **Constant-MCS exclusion** (Teammate C, HIGH confidence): If all limit_dom points share the same MCS A with phi in A, then F(phi) in A (by seriality), so Prior-UZ gives U(phi, neg phi) in A. The C5 truth lemma (`limit_satisfies_c5_strong`) then requires a witness y with neg phi in limit_f(y) = A, contradicting phi in A by MCS consistency. This eliminates the constant-MCS case entirely.

2. **M = L proof** (Teammate A, HIGH confidence): The pred-chain infimum M equals the orbit limit L. If M > L, then succ(orbit point) would place a limit_dom point in the gap (L, M), contradicting orbit_below_L and h_lt_pred_chain.

3. **Non-constant case** (All teammates, LOW confidence): With constant-MCS excluded, a discriminating formula phi exists (one that changes along the succ orbit). Z1 (FG(phi)->G(phi)) should force cofinality, but controlling phi truth at ALL future points (not just orbit points) is the unsolved difficulty.

### Prior Plan Reference

No prior plan.

### Roadmap Alignment

- Advances "Discrete completeness" roadmap item (succ_cofinal is one of the remaining sorries on the chronicle path)
- Secondary to Reynolds pipeline (tasks 139, 140, 154, 155) which is the primary path to sorry-free `bx_completeness`
- Even partial results (constant-MCS exclusion, M=L) narrow the gap and document the difficulty for future work

## Goals & Non-Goals

**Goals**:
- Formalize the constant-MCS exclusion argument (Prior-UZ + truth lemma contradiction)
- Attempt the non-constant case gap elimination using Z1, backward_G, and the available infrastructure
- Eliminate the sorry at line 1885 if the full proof succeeds
- If full proof is not achievable, document exactly what sub-cases are resolved and what remains

**Non-Goals**:
- Modifying the Reynolds pipeline (tasks 154-155) -- that is an independent path
- Adding new axioms or changing the proof system
- Proving succ_cofinal for the dense case (not applicable)
- Spending more than 3 phases on the non-constant case if stuck (hard stopping rule)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Prior-UZ exclusion argument fails in Lean (truth lemma doesn't apply as expected in gap context) | H | M | Phase 2 is a validation phase; if it fails, return partial immediately with detailed blocker documentation |
| Non-constant case gap elimination requires construction-level arguments (200-400 lines of new infrastructure) | H | H | Hard stopping rule: if Phase 3 does not produce a working proof within budget, return partial and document what's needed |
| Existing proof infrastructure (backward_G, orbit_below_L, etc.) is insufficient to close the gap | H | M | Systematically inventory available lemmas in Phase 1; if critical pieces are missing, note them early |
| Z1 application requires sub-formula closure finiteness, which is not yet formalized | M | M | Check if the discriminating formula argument can avoid the finiteness requirement by using a specific formula from Prior-UZ directly |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4 | 3 |

Phases within the same wave can execute in parallel.

### Phase 1: Infrastructure Inventory and Scaffold [NOT STARTED]

**Goal**: Inspect the sorry site with lean_goal to understand the exact proof state, inventory all available lemmas and hypotheses, and determine the precise Lean types needed for the constant-MCS exclusion argument.

**Tasks**:
- [ ] Use `lean_goal` at line 1885 (the sorry) to capture the exact goal state and all available hypotheses
- [ ] Use `lean_hover_info` on `limit_satisfies_c5_strong`, `theorem_in_mcs`, `z1_in_mcs`, `backward_G`, `backward_F`, `orbit_below_L` to confirm their signatures
- [ ] Identify whether Prior-UZ is directly available as a hypothesis or needs to be derived via `theorem_in_mcs` + `Axiom.prior_UZ`
- [ ] Document the exact type of the discriminating formula needed: determine how `limit_f A h_mcs x.val` relates to MCS membership at each orbit/pred-chain point
- [ ] Determine whether `limit_satisfies_c5_strong` can be applied within the by_contra context (i.e., whether the right hypotheses are in scope)

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- None (read-only inspection phase)

**Verification**:
- Goal state at the sorry is fully documented
- All available hypothesis names and types are catalogued
- A concrete plan for Phase 2 is confirmed or adjusted based on actual proof state

---

### Phase 2: Constant-MCS Exclusion via Prior-UZ [NOT STARTED]

**Goal**: Prove that the constant-MCS scenario (all limit_dom points in the gap share the same MCS) leads to a contradiction, eliminating that case from the gap analysis. This is the Teammate C breakthrough finding.

**Tasks**:
- [ ] Within the sorry block, introduce a case split on whether there exists a discriminating formula (a formula phi such that phi is in limit_f of some orbit point but not in limit_f of some pred-chain point, or vice versa)
- [ ] In the "no discriminating formula" branch (constant-MCS): for any formula phi, show phi is in limit_f(x) iff phi is in limit_f(y) for all x, y in the gap region
- [ ] Derive F(phi) in limit_f(x) for an orbit point x using `backward_F` (since phi is at all points above x, in particular at pred-chain points)
- [ ] Apply Prior-UZ via `theorem_in_mcs`: from F(phi) in limit_f(x), derive U(phi, neg phi) in limit_f(x) using `SetMaximalConsistent.implication_property` and `theorem_in_mcs h_mcs_x (DerivationTree.axiom [] _ (Axiom.prior_UZ phi))`
- [ ] Apply `limit_satisfies_c5_strong` to U(phi, neg phi) to obtain a witness y with neg phi in limit_f(y) and phi in the guard
- [ ] Derive contradiction: neg phi in limit_f(y) contradicts phi in limit_f(y) (the latter holds by constant-MCS assumption)
- [ ] If the argument does not go through cleanly (e.g., the witness y might be outside the gap region), document the precise failure point and adjust or return partial

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- replace sorry at line 1885 with beginning of the gap elimination proof (constant-MCS branch)

**Verification**:
- The constant-MCS case branch compiles without sorry
- `lake build` succeeds (the non-constant case may still have sorry)
- The proof state in the remaining branch shows a discriminating formula hypothesis available

---

### Phase 3: Non-Constant Case Gap Elimination [NOT STARTED]

**Goal**: With constant-MCS excluded, exploit the discriminating formula to derive a contradiction using Z1, backward_G, and the orbit/pred-chain structure. This is the hard case -- apply the stopping rule if stuck.

**Tasks**:
- [ ] In the "discriminating formula exists" branch, obtain a concrete phi that differs between some orbit point and some pred-chain point
- [ ] Attempt the Z1 argument: from the discriminating formula, derive FG(phi) or FG(neg phi) at an orbit point using backward_G (phi holds at all sufficiently late orbit points) and backward_F
- [ ] Apply z1_in_mcs to get G(G(phi)->phi) -> (FG(phi)->G(phi)) in the MCS
- [ ] Use the Z1 consequence to derive either G(phi) at the orbit point (contradiction with gap) or a "maximum point" where phi holds but G(neg phi) holds
- [ ] If the maximum point argument works: show the maximum point must be in the orbit (via orbit_below_L), then succ of that point is also orbit, and derive contradiction from forward_G giving neg phi at succ but phi at succ (by orbit membership)
- [ ] **STOPPING RULE**: If after 2 hours of effort the non-constant case does not yield a compiling proof, STOP. Document the exact proof state, what was tried, and what's needed. Return partial status.

**Timing**: 2.5 hours (hard cap)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- continue the gap elimination proof in the non-constant branch

**Verification**:
- Either: the non-constant case compiles without sorry (full success), OR
- The proof reaches a well-documented partial state with a focused sorry and clear documentation of what's needed to close it

---

### Phase 4: Integration, Verification, and Documentation [NOT STARTED]

**Goal**: Verify the complete proof (if achieved) or document partial results. Update docstrings and ensure the sorry state is accurately reflected.

**Tasks**:
- [ ] Run `lake build` on the full project to check for regressions
- [ ] If sorry-free: update the docstring at lines 1540-1557 to reflect the actual proof strategy used
- [ ] If sorry-free: update the comment block at lines 1811-1825 ("Status: This sorry represents...") to reflect resolution
- [ ] If partial: update the sorry-site comments to document which cases are resolved (constant-MCS) and what remains (non-constant case specifics)
- [ ] If partial: ensure any new helper lemmas or intermediate results are well-documented for future work
- [ ] Run `lean_verify` on `succ_cofinal` if sorry-free to confirm no axiom leaks

**Timing**: 1 hour

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- docstring and comment updates

**Verification**:
- `lake build` passes without new errors
- If sorry-free: `lean_verify succ_cofinal` reports clean (no sorry axiom)
- If partial: sorry count is reduced and remaining sorry is well-scoped with clear documentation

## Testing & Validation

- [ ] `lake build` compiles the full project without new errors
- [ ] If sorry-free: `lean_verify` on `succ_cofinal` and `limitDomSubtype_isSuccArchimedean` confirms no axiom leaks
- [ ] If sorry-free: downstream consumers (`limitDomSubtype_isSuccArchimedean`, `succ_embed_surjective`, collapse pipeline) inherit sorry-free status
- [ ] Proof structure matches the mathematical argument (constant-MCS exclusion via Prior-UZ, then non-constant case via Z1 or alternative)

## Artifacts & Outputs

- `plans/02_succ-cofinal-plan.md` (this file)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (modified)
- `summaries/02_succ-cofinal-summary.md` (on completion)

## Rollback/Contingency

If the implementation introduces regressions or the proof approach is fundamentally flawed:
1. `git checkout -- Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` to restore the original sorry
2. The sorry was self-contained at line 1885; reverting does not affect other proofs
3. If partial progress is valuable (e.g., constant-MCS exclusion compiles), preserve it in a separate branch or with a focused sorry replacing the broader one
4. The Reynolds pipeline (tasks 154-155) bypasses succ_cofinal entirely and is the primary fallback
