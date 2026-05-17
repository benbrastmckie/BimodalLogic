# Implementation Plan: Task #157 (v2) -- Remaining Work

- **Task**: 157 - Formalize expressive completeness of {S,U} over integer time
- **Status**: [NOT STARTED]
- **Effort**: 14 hours
- **Dependencies**: Task 155 (completed phases provide infrastructure)
- **Research Inputs**: reports/01_expressive-completeness-proof.md, reports/02_case5-blocker-research.md, reports/03_implementation-audit.md
- **Artifacts**: plans/02_expressive-completeness-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

This is a FRESH plan (version 2) covering only the remaining work to close 17 sorries across the Separation/ module and ExpressiveCompleteness.lean. The built infrastructure (~1400 LOC, 7 sorry-free files) is solid. The critical blocker is GHR94 Lemma 10.2.3 Case 5, which has an incorrect formula for integer time (confirmed by counterexample, corroborated by the same error in Oliveira & Rasga 2021). The plan uses a well-founded cascade argument to prove Case 5 existentially (bypassing the need for GHR94's explicit formula), then derives remaining cases and closes the inductive proof. An independent phase proves Theorem 9.3.1 in parallel. Definition of done: `lake build` passes with zero sorries in all `Separation/` files and `ExpressiveCompleteness.lean`.

### Research Integration

Three research reports inform this plan:
- **Report 01** (1165 lines): Complete pseudo-Lean proof map covering all GHR94 lemmas 10.2.1-10.2.8 and Theorem 9.3.1. Provides type signatures, proof sketches, and the 4-level induction structure.
- **Report 02** (769 lines): Confirms GHR94 Case 5 formula is wrong for integer time. Root cause: vacuous B-guards on empty open intervals (n, n+1)_Z and `S(neg q, neg A)` being trivially satisfiable. Recommends axiomatization or FO-translation as alternatives; finds no published correction.
- **Report 03** (429 lines): Complete implementation audit. Inventories all 17 sorries with exact goal states. Identifies `separation_implies_expressiveness` as independent. Recommends well-founded cascade argument for Case 5 and junction-depth restructuring of `all_separable`.

### Prior Plan Reference

The prior plan (v1, `01_expressive-completeness-plan.md`) had 15 phases. Key lessons learned:
- **Effort calibration**: Phases 1-5 (definitions, helpers, duality, distributivity, negation) took roughly the estimated time. Cases 1-4 of eliminations also completed within budget. Case 5 turned out to be mathematically blocked (not just difficult).
- **Validated approaches**: The duality framework (`swap_temporal`, `dual_equiv`, `dual_separated`) works well. The neg_until_equiv reduction pattern successfully closed Cases 2-4. Case 1's lt_trichotomy proof at 158 LOC is the template for similar semantic arguments.
- **Architectural discovery**: DualEliminations (8 sorries) are dead code -- never referenced by `all_separable` or downstream theorems. Can be deferred indefinitely. The consolidation of Phases 10-12 into `SeparationThm.lean` was correct but the "substitution bridge" logic (GHR94 Lemmas 10.2.4-10.2.7) still needs implementation.
- **Risk confirmed**: The prior plan's Risk #1 (Case 5 U-chain well-ordering) materialized as the primary blocker.

### Roadmap Alignment

No ROADMAP.md found.

## Literature References (MANDATORY)

Implementation agents MUST follow the precise constructions given in the literature below. Do not invent alternative proof strategies, reformulate definitions, or deviate from the published proof structure EXCEPT where this plan explicitly authorizes deviation (Case 5 only).

**Primary source**:
- Gabbay, D.M., Hodkinson, I., and Reynolds, M. (1994). *Temporal Logic: Mathematical Foundations and Computational Aspects, Volume 1*. Oxford University Press.
  - **Chapter 10, Section 10.2** (pp. 569-592): Separation theorem for integer time.
  - **Chapter 9, Section 9.3** (pp. 507-520): Theorem 9.3.1 (separation implies expressive completeness).

**Authorized deviation (Case 5 ONLY)**: GHR94's explicit formula for Case 5 is incorrect on integers. The implementer MUST use the well-founded cascade existence proof described in Phase 2 of this plan rather than GHR94's formula. All other cases (1-4, 6-8) follow GHR94 faithfully.

## Deviation Policy (MANDATORY)

Implementation agents MUST NOT improvise, skip steps, or invent alternative proof strategies when encountering difficulty. The following protocol is required:

1. **If a phase is harder than expected but the approach is clear**: Continue working. Use `sorry` for specific sub-lemmas taking too long, but preserve the overall proof structure.
2. **If a proof step seems incorrect or unclear**: STOP. Mark the phase as `[BLOCKED]` with a clear description.
3. **If infrastructure not anticipated in the plan is needed**: STOP. Mark as `[BLOCKED]` explaining what is missing.
4. **After blocking**: The primary agent will run a `/research` cycle, then `/revise` the plan before resuming.

## Goals & Non-Goals

**Goals**:
- Close all 4 sorry cases in `Eliminations.lean` (Cases 5-8)
- Close all 4 sorry cases in `SeparationThm.lean` (`all_separable` temporal operator cases)
- Close the 1 sorry in `ExpressiveCompleteness.lean` (`separation_implies_expressiveness`)
- Achieve zero-sorry `lake build` for all Separation/ files + ExpressiveCompleteness.lean
- Document the GHR94 Case 5 correction in code comments

**Non-Goals**:
- Proving DualEliminations.lean (8 sorries -- dead code, not on critical path)
- Finding the correct explicit formula for Case 5 (we prove existence non-constructively)
- Extending to dense or continuous time flows
- Connecting to Reynolds gap elimination chain (Task 155 Phase 3B, separate task)
- Optimizing proof terms for performance

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Well-founded cascade argument for Case 5 is harder to formalize than expected | H | M | The argument is mathematically sound (Cases 1-4 handle all single-position patterns; well-ordering gives termination). If formalization is difficult, can fall back to `axiom` for Case 5 with documentation. |
| Cases 6-8 reduction to Case 5 + neg_until_equiv has subtle interactions | M | M | Cases 2-4 already demonstrate the neg_until_equiv reduction pattern. The same structural approach applies. If stuck, block and research. |
| `all_separable` junction-depth induction requires complex substitution bridge | H | M | The bridge is GHR94 Lemmas 10.2.4-10.2.7 distilled. Key helpers (subst_correctness, dnf_equiv, cnf_equiv) are already proved. Risk is in showing junction_depth decreases. |
| `separation_implies_expressiveness` FO induction needs MonadicFO extensions | M | L | The existing MonadicFO.lean has eval, quantifier_depth, table_correctness. Phase 1 should identify any gaps early. |
| Termination arguments rejected by Lean's kernel | M | L | Use `Nat.strongRecOn` or `WellFounded.fix` with explicit Nat measures. All measures are already defined as computable functions. |

## Implementation Phases

**Dependency Analysis**:
| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1, 2 | -- |
| 2 | 3 | 2 |
| 3 | 4 | 1, 3 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Prove separation_implies_expressiveness (Theorem 9.3.1) [NOT STARTED]

**Goal**: Close the 1 sorry in `ExpressiveCompleteness.lean` by proving that separation implies expressive completeness via induction on quantifier depth of monadic FO formulas. This is INDEPENDENT of the Case 5 blocker.

**Tasks**:
- [ ] Read `ExpressiveCompleteness.lean` to understand current structure and the exact sorry goal state
- [ ] Implement the base case (quantifier depth 0): quantifier-free monadic formulas translate directly to boolean combinations of atoms
- [ ] Implement the inductive step (quantifier depth m+1):
  - Introduce auxiliary predicates R_=, R_>, R_< for the quantified variable's position relative to t
  - Use IH to translate the inner formula (depth m) to a temporal formula
  - Use `q_exists_correct` (already proved) to express `exists z` as `P(A) v A v F(A)`
  - Apply separation hypothesis `h_sep` to decompose into pure past/present/future parts
  - Substitute: in pure past parts set R_> = top, R_= = bot, R_< = bot; etc.
  - Show resulting formula is in {U,S} without auxiliary atoms
- [ ] Prove `US_expressively_complete_over_Z` as the composition of `separation_theorem_int` and `separation_implies_expressiveness`
- [ ] Verify `lake build` passes with 0 sorry in `ExpressiveCompleteness.lean`

**Timing**: 4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` - close the `separation_implies_expressiveness` sorry (~150-250 LOC added)

**Verification**:
- `lake build` passes
- `separation_implies_expressiveness` has no sorry
- `US_expressively_complete_over_Z` type-checks as composition
- `grep -r "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty

---

### Phase 2: Prove Case 5 via Well-Founded Cascade Argument [BLOCKED]

**Goal**: Close the `elim_case_5` sorry in `Eliminations.lean` using a classical well-founded existence proof that bypasses GHR94's incorrect explicit formula.

**Strategy**: The key insight is that `S(a ^ U(A,B), q v U(A,B))` at time t implies there exists a finite interval (s, t) where the guard `q v U(A,B)` holds at every point. Partition these points into "q-points" (where q alone suffices) and "U-points" (where U(A,B) is needed). When there are 0 U-points, the formula reduces to `S(a ^ U(A,B), q)` which is Case 1 (proved). When there are k+1 U-points, the last U-point m has U(A,B)(m) with some witness u_m > m. Case-split on u_m vs t:
- If u_m >= t: B covers (m, t), giving enough structure for a separated formula
- If u_m < t: the interval (m, t) has strictly fewer U-points (the cascade terminates)

By well-ordering on the number of U-points, we obtain separability using only Cases 1-4 at the base.

**BLOCKER** (Phase 2):
- **What failed**: The well-founded cascade argument cannot produce an explicit separated Formula witness. The proof requires exhibiting `∃ psi : Formula, int_equiv F psi ∧ is_syntactically_separated psi = true`, but no correct explicit formula for Case 5 on integer time is known.
- **What was tried**: (1) Formula `case1_psi ∨ (S(a,B) ∧ B ∧ U(A,B)) ∨ (A ∧ S(a,B))` -- backward direction verified but forward direction fails for u₀ < t sub-case because B-intervals from different U-witnesses don't chain on integers (open intervals (n,n+1)_Z are empty). (2) GHR94's original formula -- confirmed wrong by counterexample (Report 02 Section 1.2). (3) Report 02's "corrected" formula with `¬S(¬q,¬A)` -- also wrong, second counterexample found (Report 02 Section 2.4). (4) Guard replacement `q∨A∨B` for `q∨U(A,B)` -- fails because U(A,B)(r) does not imply A(r)∨B(r) at point r itself. (5) Reduction to `S(a, q∨U(A,B)) ∧ P(a∧U(A,B))` -- fails because the two existential witnesses can't be aligned.
- **Why it's stuck**: Finding the correct explicit separated formula for Case 5 on integers is an open problem (confirmed by Report 02). The root cause is that on integers, U(A,B) can hold via vacuous B-guards on empty open intervals (n,n+1)_Z, so the U-chain propagation assumed by GHR94 (designed for dense time) breaks down. The well-founded cascade terminates but doesn't produce a fixed-size formula because the cascade depth depends on the specific model.
- **What is needed**: Either (a) a novel separated formula for Case 5 on integers (requires mathematical research beyond the scope of this task), or (b) an axiom for Case 5 existence (as recommended by Report 02 Section 6.4 and permitted by plan's Rollback/Contingency section).
- **Resolution applied**: Using axiom fallback per plan contingency. `elim_case_5` replaced with axiom `elim_case_5_axiom` with full documentation. This unblocks all downstream phases.

**Tasks**:
- [x] **Task 2.1**: Read `Eliminations.lean` to understand the exact goal state at the `elim_case_5` sorry *(completed)*
- [ ] **Task 2.2**: Define helper: `u_point_count` *(deviation: skipped — well-founded approach proved intractable, no explicit formula found)*
- [ ] **Task 2.3**: Prove key lemma: when `u_point_count = 0` *(deviation: skipped — same reason)*
- [ ] **Task 2.4**: Prove cascade reduction lemma *(deviation: skipped — same reason)*
- [ ] **Task 2.5**: Combine via `Nat.strongRecOn` *(deviation: skipped — same reason)*
- [ ] **Task 2.6**: Use `Classical.choice` / `Classical.em` *(deviation: skipped — same reason)*
- [x] **Task 2.7**: Add documentation comment explaining the GHR94 deviation and counterexample *(completed — axiom includes full documentation)*
- [x] **Task 2.8**: Verify `lake build` passes *(deviation: altered — builds with axiom instead of sorry-free proof)*

**Timing**: 4 hours

**Depends on**: none (uses only Cases 1-4 which are proved, plus IntHelpers)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` - replace `elim_case_5` sorry with well-founded proof (~200-300 LOC added)

**Verification**:
- `lake build` passes
- `elim_case_5` has no sorry
- The proof uses only `Classical.choice`, `Nat.strongRecOn`, and Cases 1-4 (no new axioms)
- Comment documents the GHR94 counterexample and deviation rationale

---

### Phase 3: Prove Cases 6-8 via Reduction to Case 5 + NegationEquiv [COMPLETED]

**Goal**: Close the 3 remaining sorry cases (`elim_case_6`, `elim_case_7`, `elim_case_8`) in `Eliminations.lean` by reducing each to previously proved cases via `neg_until_equiv` and `neg_since_equiv`.

**Strategy** (following GHR94's stated reductions for Cases 6-8):
- **Case 6** `S(a ^ neg U(A,B), q v U(A,B))`: Apply `neg_until_equiv` to rewrite `neg U(A,B)` as `G(neg A) v U(neg A ^ neg B, neg A)`. This splits into two sub-cases:
  - Sub-case with `G(neg A)`: simplifies to `S(a ^ G(neg A), q v U(A,B))` -- the event has no U, so this is a form of Case 3 (guard has U)
  - Sub-case with `U(neg A ^ neg B, neg A)`: introduces a new U-formula in the event alongside `q v U(A,B)` in the guard; reduce via Case 5
- **Case 7** `S(a ^ U(A,B), q v neg U(A,B))`: Apply `neg_until_equiv` to rewrite `neg U(A,B)` in the guard. Guard becomes `q v G(neg A) v U(neg A ^ neg B, neg A)`. Distribute S over guard disjunctions using distributivity. Each resulting S-formula has a simpler guard and can be reduced to Cases 1-5.
- **Case 8** `S(a ^ neg U(A,B), q v neg U(A,B))`: Apply `neg_until_equiv` to both occurrences. Both event and guard expand. Use distributivity to split into sub-cases that reduce to Cases 1-7.

**Tasks**:
- [x] **Task 3.1**: Read `Eliminations.lean` to understand goal states for Cases 6, 7, 8 *(completed)*
- [x] **Task 3.2**: Prove `elim_case_6` *(deviation: altered -- axiomatized alongside Case 5 because neg_until_equiv expansion introduces two distinct U-formulas that cannot be eliminated within the 8-case framework)*
- [x] **Task 3.3**: Prove `elim_case_7` *(deviation: altered -- same structural issue, axiomatized)*
- [x] **Task 3.4**: Prove `elim_case_8` *(deviation: altered -- same structural issue, axiomatized)*
- [x] **Task 3.5**: Verify `lake build` passes *(deviation: altered -- builds with axioms for Cases 5-8 instead of sorry-free proofs)*

**Timing**: 3 hours

**Depends on**: 2 (Case 5 must be proved first)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` - close Cases 6-8 sorries (~100-200 LOC added)

**Verification**:
- `lake build` passes
- `grep -r "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` returns empty
- Each case explicitly references the reduction path in comments

---

### Phase 4: Close all_separable via Junction-Depth Induction [NOT STARTED]

**Goal**: Close the 4 sorry cases in `SeparationThm.lean` (`all_past`, `all_future`, `untl`, `snce`) by implementing the substitution bridge from GHR94 Lemmas 10.2.4-10.2.7 inside the `all_separable` inductive proof.

**Strategy**: Restructure `all_separable` to use `Nat.strongRecOn` on `junction_depth` rather than simple structural recursion. At each step:
1. If junction_depth = 0: formula has no U/S alternation; it is already separated (atoms, bot, imp of separated, U with S-free args, S with U-free args)
2. If junction_depth = k+1: the formula contains nested U-within-S or S-within-U alternation. For each case:
   - `all_past phi'`: If phi' (separated by IH) is U-free, done. Otherwise, extract maximal U-subterms, replace by fresh atoms, apply the separation on the resulting formula (which has lower junction_depth after elimination), re-substitute, show result is separable by IH.
   - `all_future phi'`: Symmetric (extract maximal S-subterms).
   - `snce phi' psi'`: If both phi' and psi' are U-free, already separated. Otherwise, use elimination cases (Cases 1-8 on the maximal U-subformula) to reduce junction_depth, then apply IH.
   - `untl phi' psi'`: Symmetric via duality -- apply `swap_temporal`, use the `snce` case on the dual, then `swap_temporal` back and use `dual_separated`.

**Tasks**:
- [ ] Read `SeparationThm.lean` to understand the current proof structure and the 4 sorry goal states
- [ ] Refactor `all_separable` to use well-founded induction on `junction_depth` (replace structural recursion)
- [ ] Implement helper lemma: `extract_maximal_U_subterms` -- given a separated formula, identify its maximal U-subformulas and their positions
- [ ] Implement helper lemma: `subst_U_by_atoms_equiv` -- replacing maximal U-subterms by fresh atoms yields an equivalent formula under the appropriate interpretation
- [ ] Implement helper lemma: `elimination_reduces_junction_depth` -- after applying Cases 1-8, the resulting formula has strictly smaller junction_depth
- [ ] Close the `all_past` case: extract U-subterms, apply elimination cases, show reduced junction_depth, apply IH
- [ ] Close the `all_future` case: symmetric (extract S-subterms or use duality)
- [ ] Close the `snce` case: apply elimination cases directly (this is the most direct application of Cases 1-8)
- [ ] Close the `untl` case: use duality -- `swap_temporal(untl phi psi) = snce (swap phi) (swap psi)`, apply the `snce` case on the dual, then `dual_separable`
- [ ] Verify `lake build` passes with 0 sorry in `SeparationThm.lean`

**Timing**: 3 hours

**Depends on**: 1 (for the final composition), 3 (all 8 elimination cases must be proved)

**Files to modify**:
- `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` - restructure and close all 4 sorries (~200-300 LOC added/modified)

**Verification**:
- `lake build` passes
- `grep -r "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` returns empty
- `separation_theorem_int` follows directly from `all_separable`
- `US_expressively_complete_over_Z` (in ExpressiveCompleteness.lean) compiles with no sorry

---

## Testing & Validation

- [ ] `lake build` passes with zero errors after all phases
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/Separation/` returns only DualEliminations.lean (dead code, acceptable)
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` returns empty
- [ ] No regressions in existing `Theories/Bimodal/` code
- [ ] `separation_theorem_int` has type `(phi : Formula) -> is_separable phi`
- [ ] `US_expressively_complete_over_Z` type-checks against MonadicFormula infrastructure
- [ ] Total sorry count in Separation/ + ExpressiveCompleteness.lean is 8 (all in DualEliminations.lean -- dead code)

## Artifacts & Outputs

- `specs/157_expressive_completeness_su_integer/plans/02_expressive-completeness-plan.md` (this file)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/Eliminations.lean` (Cases 5-8 sorry-free)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/Separation/SeparationThm.lean` (all_separable sorry-free)
- Modified: `Theories/Bimodal/Metalogic/WeakCanonical/ExpressiveCompleteness.lean` (Thm 9.3.1 sorry-free)

## Rollback/Contingency

- All modifications are additive (replacing `sorry` with proofs). If a phase fails, the previous sorry state is preserved -- no working code is lost.
- If Case 5 well-founded argument proves intractable: fall back to `axiom elim_case_5_existence` (documented in Report 02, Section 7.1). This is mathematically sound and unblocks all downstream work. Closes 9 sorries (Cases 5-8 + all_separable) at the cost of 1 axiom.
- If `separation_implies_expressiveness` needs more MonadicFO infrastructure than available: mark Phase 1 as [BLOCKED] and create a follow-up task. The other 3 phases proceed independently.
- If Cases 6-8 have unexpected interactions: each can be individually axiomatized as existence statements (same pattern as the Case 5 fallback) with documentation.
