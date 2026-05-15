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

### Phase 1: Infrastructure Inventory and Scaffold [COMPLETED]

**Goal**: Inspect the sorry site with lean_goal to understand the exact proof state, inventory all available lemmas and hypotheses, and determine the precise Lean types needed for the constant-MCS exclusion argument.

**Tasks**:
- [x] Use `lean_goal` at line 1885 (the sorry) to capture the exact goal state and all available hypotheses *(completed)*
- [x] Use `lean_hover_info` on `limit_satisfies_c5_strong`, `theorem_in_mcs`, `z1_in_mcs`, `backward_G`, `backward_F`, `orbit_below_L` to confirm their signatures *(completed)*
- [x] Identify whether Prior-UZ is directly available as a hypothesis or needs to be derived via `theorem_in_mcs` + `Axiom.prior_UZ` *(completed -- Prior-UZ available via `DerivationTree.axiom [] _ (Axiom.prior_UZ φ)` + `theorem_in_mcs`)*
- [x] Document the exact type of the discriminating formula needed: determine how `limit_f A h_mcs x.val` relates to MCS membership at each orbit/pred-chain point *(completed)*
- [x] Determine whether `limit_satisfies_c5_strong` can be applied within the by_contra context (i.e., whether the right hypotheses are in scope) *(completed -- yes, c5_strong takes A, h_mcs, x, hx, ξ, η, h_until as arguments; all available in scope)*

**Phase 1 Findings**:
- Goal at sorry is `False` in `case neg` with L ≤ pb.val (pred(b).val)
- Key hypotheses: orbit s^[n] a → L, pred-chain p^[k] pb ≥ L (strictly decreasing), all orbit < all pred-chain
- backward_G, backward_F, _backward_P all proved and available locally
- z1_in_mcs available: places Z1 = G(Gφ→φ)→(FGφ→Gφ) in every MCS
- Prior-UZ available via axiom + theorem_in_mcs: F(φ) → U(φ, ¬φ) in every MCS
- limit_satisfies_c5_strong: U(η, ξ) ∈ limit_f(x) gives witness y > x with η at y and ξ guard
- **CRITICAL FINDING**: The constant-MCS exclusion argument from the research report is FLAWED. The c5_strong for U(φ, ¬φ) gives φ at witness y and ¬φ at *intermediates*, NOT ¬φ at y. In the discrete case, the immediate successor has no intermediates, so the guard is vacuously satisfied. No contradiction.
- **CRITICAL FINDING**: The code comments at line 1139-1156 document that the gap scenario is consistent with all temporal axioms (Z1, Prior-UZ) in the constant-MCS case under strict (irreflexive) semantics. G(φ)→φ is not valid in strict semantics.

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- None (read-only inspection phase)

**Verification**:
- Goal state at the sorry is fully documented
- All available hypothesis names and types are catalogued
- A concrete plan for Phase 2 is confirmed or adjusted based on actual proof state

---

### Phase 2: Constant-MCS Exclusion via Prior-UZ [BLOCKED]

**Goal**: Prove that the constant-MCS scenario (all limit_dom points in the gap share the same MCS) leads to a contradiction, eliminating that case from the gap analysis. This is the Teammate C breakthrough finding.

**BLOCKER** (Phase 2):
- **What failed**: The constant-MCS exclusion argument from the research report is fundamentally flawed.
- **What was tried**:
  1. Constructed F(top) at orbit point a via backward_F (compiles)
  2. Applied Prior-UZ to get U(top, neg top) at orbit point a (compiles)
  3. Applied limit_satisfies_c5_strong to U(phi, neg phi) -- but the witness y has phi at y (the event) and neg phi at *intermediates* (the guard), NOT neg phi at y
  4. In the discrete case, y = immediate successor = next orbit point. The guard is vacuously satisfied (no intermediates). No contradiction.
  5. Tried varying formulas (top, any phi in constant MCS, neg phi). All fail for the same reason: the c5_strong guard is empty between consecutive points.
  6. Examined Z1: G(Gφ→φ)→(FGφ→Gφ). In strict (irreflexive) semantics, G(Gφ→φ) is trivially satisfied in the constant-MCS case (Gφ and φ are both in every MCS). Z1 conclusion Gφ is also in every MCS. No information gained.
  7. Examined whether gap points between orbit and pred-chain lead to contradiction: gap points' predecessors either give orbit points (contradiction via value < L = succ value ≥ L) or give more gap points (infinite descent, no contradiction).
- **Why it's stuck**: The research report (Teammate C) confused the c5_strong conclusion. The C5 truth lemma for U(η, ξ) gives η at the witness y and ξ at *intermediates*, NOT ξ at y. In the discrete case, there are no intermediates between consecutive points, so the guard ξ is vacuously satisfied regardless of what ξ is. The constant-MCS scenario is genuinely consistent with all temporal axioms (Z1, Prior-UZ) under strict (irreflexive) semantics. This is confirmed by the code comments at lines 1139-1156.
- **What is needed**: Either (a) a construction-level argument showing the omega-chain can't produce a Z+Z gap (requires deep interaction with omega_chain_elim_result, BurgessR3Maximal, etc.), or (b) the task 129 approach (weak/reflexive completeness + conservative extension) that bypasses the gap entirely.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Tasks**:
- [ ] Within the sorry block, introduce a case split on whether there exists a discriminating formula *(deviation: skipped -- the case split is moot because neither branch produces a contradiction with current infrastructure)*
- [ ] In the "no discriminating formula" branch (constant-MCS): for any formula phi, show phi is in limit_f(x) iff phi is in limit_f(y) for all x, y in the gap region *(deviation: skipped -- constant-MCS exclusion argument is flawed)*
- [ ] Derive F(phi) in limit_f(x) for an orbit point x using `backward_F` *(deviation: altered -- verified compiles but leads nowhere)*
- [ ] Apply Prior-UZ via `theorem_in_mcs`: from F(phi) derive U(phi, neg phi) *(deviation: altered -- verified compiles but c5_strong gives empty guard in discrete case)*
- [ ] Apply `limit_satisfies_c5_strong` to U(phi, neg phi) to obtain witness *(deviation: skipped -- guard is vacuously satisfied, no contradiction)*
- [ ] Derive contradiction *(deviation: skipped -- no contradiction derivable from this approach)*
- [x] If the argument does not go through cleanly, document the precise failure point *(completed -- see BLOCKER above)*

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- replace sorry at line 1885 with beginning of the gap elimination proof (constant-MCS branch)

**Verification**:
- The constant-MCS case branch compiles without sorry
- `lake build` succeeds (the non-constant case may still have sorry)
- The proof state in the remaining branch shows a discriminating formula hypothesis available

---

### Phase 3: Non-Constant Case Gap Elimination [BLOCKED]

**Goal**: With constant-MCS excluded, exploit the discriminating formula to derive a contradiction using Z1, backward_G, and the orbit/pred-chain structure. This is the hard case -- apply the stopping rule if stuck.

**BLOCKER** (Phase 3):
- **What failed**: The Z1 argument is blocked in BOTH constant and non-constant cases under strict (irreflexive) semantics.
- **What was tried**: Analysis of Z1 = G(Gφ→φ) → (FGφ → Gφ) application at orbit points. In strict semantics, G(Gφ→φ) does not imply Gφ→φ at the current point (G quantifies over strictly future points). So the "backward induction from Gφ witness" doesn't anchor at the orbit point. The code comments at line 1143 confirm: "Under strict semantics G(φ)→φ is not valid."
- **Why it's stuck**: The Z1 Doets maximum principle requires establishing G(Gφ→φ) at an orbit point, which in turn requires showing Gφ→φ at ALL strictly future points. In the non-constant case, a discriminating formula φ exists, but controlling φ's truth at ALL future points (not just orbit or pred-chain points) requires knowledge about ALL limit_dom points in the gap region. This is the unsolved difficulty documented in the code comments at lines 1877-1884.
- **What is needed**: Same as Phase 2 -- either a construction-level argument or the task 129 approach.
- **Prohibited workarounds**: Do NOT use `sorry`, `def X := True`, or any vacuous placeholder.

**Tasks**:
- [ ] In the "discriminating formula exists" branch, obtain a concrete phi *(deviation: skipped -- Phase 2 not resolved, and Z1 argument blocked independently)*
- [ ] Attempt the Z1 argument *(deviation: skipped -- Z1 blocked under strict semantics per line 1143)*
- [ ] Apply z1_in_mcs *(deviation: skipped)*
- [ ] Use the Z1 consequence to derive contradiction *(deviation: skipped)*
- [ ] Maximum point argument *(deviation: skipped)*
- [x] **STOPPING RULE**: Invoked. Sorry is genuinely beyond current infrastructure. *(completed)*

**Timing**: 2.5 hours (hard cap)

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` -- continue the gap elimination proof in the non-constant branch

**Verification**:
- Either: the non-constant case compiles without sorry (full success), OR
- The proof reaches a well-documented partial state with a focused sorry and clear documentation of what's needed to close it

---

### Phase 4: Integration, Verification, and Documentation [COMPLETED]

**Goal**: Verify the complete proof (if achieved) or document partial results. Update docstrings and ensure the sorry state is accurately reflected.

**Tasks**:
- [x] Run `lake build` on the full project to check for regressions *(completed -- build passes, no new errors)*
- [ ] If sorry-free: update the docstring at lines 1540-1557 *(deviation: skipped -- sorry not resolved)*
- [ ] If sorry-free: update the comment block *(deviation: skipped -- sorry not resolved)*
- [x] If partial: update the sorry-site comments to document which cases are resolved and what remains *(completed -- updated comments at lines 1842-1887 and section docstring at lines 1134-1160)*
- [x] If partial: ensure any new helper lemmas or intermediate results are well-documented for future work *(completed -- no new helper lemmas; documentation updated in comments)*
- [ ] Run `lean_verify` on `succ_cofinal` if sorry-free *(deviation: skipped -- sorry not resolved)*

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
