# Implementation Plan: Task #107 -- Burgess Chronicle Construction (Complete Sorry Elimination, Revised)

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [NOT STARTED]
- **Effort**: 25-41 hours
- **Dependencies**: None (self-contained within Chronicle/ and Completeness.lean)
- **Research Inputs**: reports/62_team-research.md, reports/60_full-audit.md
- **Artifacts**: plans/62_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close all 13 remaining sorry sites across PointInsertion.lean (3), CounterexampleElimination.lean (7), ChronicleToCountermodel.lean (2), and Completeness.lean (1) to deliver a fully sorry-free completeness theorem for TM bimodal logic via the Burgess 1982 chronicle construction. The root dependency is NoUnivBurgessR3 (#13), which is NOT a J0 theorem (confirmed by semantic counterexample on 2-point discrete order) and requires either a definition fix (add SetConsistent B to burgessR3) or a construction-level proof (dense Q domain has no adjacent pairs with empty guard intervals). After resolving #13, the plan follows the Burgess DAG: Lemma 2.6 Case B (#1), Lemma 2.7 seed consistency (#2) and inconsistent case (#3), c2' plumbing (#6-10), C4/C4' hard cases (#4-5), and FUC/FSC coherence (#11-12). Definition of done: `#print axioms bx_completeness` shows no `sorryAx`; `lake build` succeeds; `grep -rn "sorry" Chronicle/` returns only comments.

### Research Integration

**Report 62 (team-research.md)**: Four-teammate analysis confirming 13 sorry sites. Key findings: (1) NoUnivBurgessR3 is NOT a J0 theorem, requiring definition fix or semantic proof. (2) Sorries #1 and #3 are formalization artifacts from case splits Burgess never makes. (3) Mirror symmetry halves unique proof obligations (#4/#5, #6/#7, #8/#9, #11/#12). (4) c2' architecture gap is architectural (return type), not mathematical. (5) Lemma 2.7 seed consistency (#2) is hardest: 12-step BX5+BX7+A3a chain. (6) Case B (#1) is NOW closable after ClosedUnderDerivation cascade.

### Prior Plan Reference

Plan v60 had 8 phases (30-42h). Phases 1-2 completed (build fix + BX7 infrastructure). Phase 3 reached PARTIAL (Case A proved, Case B blocked). Plan is significantly stale: sorry count was 12 (now 13 with NoUnivBurgessR3), Phase 3 blocker claim is false after ClosedUnderDerivation cascade, Phase 6 claimed "7 CE sorries" (actually 2 standalone + 5 inline). Effort calibration from v60: convention alignment was critical (now resolved), D2 elimination in BX7 needs careful verification, c2' co-construction is highest-effort single block.

### Roadmap Alignment

- Task 107 is the primary completeness path (Chronicle construction)
- Advances: "4 sorry sites remain across 3 files" toward 0
- Closes the completeness theorem for TM bimodal logic (representation theorem goal)

## Goals & Non-Goals

**Goals**:
- Resolve NoUnivBurgessR3 (#13) as the root dependency (cleanest available option)
- Close sorry #1 (Lemma 2.6 Case B pos sub-case) via maximality extraction
- Close sorry #2 (Lemma 2.7 seed consistency) via BX5+BX7+A3a chain per Burgess p.372
- Close sorry #3 (Lemma 2.7 inconsistent case) by removing unnecessary case split
- Close sorries #6-10 (c2' maintenance for all 5 elimination types)
- Close sorries #4-5 (C4/C4' hard cases) once c2' parameter is available
- Close sorries #11-12 (FUC/FSC coherence) via limit_satisfies_c5_full
- Deliver fully sorry-free `bx_completeness` with no `sorryAx` dependency
- Follow Burgess 1982 exactly -- no unsound axioms, no shortcuts

**Non-Goals**:
- Add `irr_until` axiom (proven unsound for discrete orders)
- Add density or discreteness axioms (would restrict completeness theorem)
- Restructure the overall chronicle construction architecture
- Generalize beyond D=Rat to arbitrary ordered groups
- Optimize proof term sizes or compilation speed
- Close BXCanonical sorries (task 109, separate)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| NoUnivBurgessR3 definition change cascades widely | Blocks all work | Medium | Audit all `burgessR3` usage before modifying. Option B (prove from construction properties) avoids definition change entirely |
| Lemma 2.7 seed consistency (#2) BX7 three-way is a 12-step chain | Blocks Phases 3-6 | Medium | Implement incrementally with `lean_goal` at each step. D2 elimination has known alternative path (right_mono to eta, then BX14) |
| c2' refactoring requires modifying EliminationResult signatures | Build churn in Phase 4 | Medium | Implement incrementally per elimination type with `lake build` after each. Keep old sorries until all cases ready |
| Case B (#1) maximality extraction is novel (no prior plan had working strategy) | Blocks Phase 2 | Low | ClosedUnderDerivation cascade already fixed the underlying issue. DC(B union {beta}) + BX2 contrapositive is well-understood |
| FUC/FSC proof depends on entire upstream chain | Late-discovered issues | Low | Each phase has independent verification. Commit at each boundary |
| Removing unnecessary case splits (#1, #3) may expose new proof obligations | Unexpected complications | Low | Verified in research: these ARE formalization artifacts. Burgess never case-splits on MCS or consistency |

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

### Phase 1: Resolve NoUnivBurgessR3 (#13) [NOT STARTED]

**Goal**: Eliminate the root dependency sorry at Completeness.lean:152 where `NoUnivBurgessR3` (the property that `burgessR3(A, Set.univ, C)` never holds for any MCS A, C) is assumed without proof. This is the foundation on which the entire chronicle construction rests -- `dd_countermodel_chronicle` takes `NoUnivBurgessR3` as a parameter.

**Paper reference**: Implicit in Burgess 1982 Section 1.3 -- DCSs are consistent by definition (a DCS is "deductively closed" and "consistent" if bot is not a consequence). In Burgess's notation, `r(A, B, C)` requires B to be a DCS, and DCSs are consistent. `Set.univ` contains bot, so it is inconsistent and cannot be a DCS in Burgess's sense.

**Strategy**: Evaluate options in order of preference:

- **Option A (cleanest)**: Add `SetConsistent B` to the `burgessR3` definition, matching Burgess's implicit requirement that B is a DCS (and DCSs are consistent). Then `burgessR3(A, Set.univ, C)` is false because `Set.univ` is not consistent. NoUnivBurgessR3 becomes trivial. Requires cascading audit of all `burgessR3` users to supply the new `SetConsistent B` hypothesis.

- **Option B (least disruptive)**: Prove NoUnivBurgessR3 from the construction's properties: the chronicle uses Q (dense, totally ordered), where g(x,y) intervals always have intermediate points (for x < y, there exists z with x < z < y). On dense orders, `untl(bot, gamma) = (bot U gamma)` is unsatisfiable because the guard interval (x,y) is never empty. Since `burgessR3(A, Set.univ, C)` requires `untl(gamma, beta) in A` for all gamma in C and all beta in Set.univ, taking beta = bot gives `untl(gamma, bot) in A`, but `untl(gamma, bot)` requires F(bot) which contradicts MCS consistency of A. So NoUnivBurgessR3 follows from the fact that A is MCS.

- **Option C (fallback)**: Add NoUnivBurgessR3 as a structural axiom with semantic justification.

**Tasks**:
- [ ] **Task 1.1**: Read the definition of `burgessR3` in ChronicleTypes.lean and all its usage sites. Determine whether `SetConsistent B` is already implied or easily added.
- [ ] **Task 1.2**: Attempt Option B first -- check whether `burgessR3(A, Set.univ, C)` can be refuted from MCS properties of A alone. Specifically: `Set.univ` contains `bot`, so `burgessR3(A, Set.univ, C)` requires `untl(gamma, bot) in A` for all gamma in C, but `untl(gamma, bot)` implies `F(bot)` (by BX10), and `F(bot) = neg G(neg bot) = neg G(top)` contradicts seriality + consistency of A.
- [ ] **Task 1.3**: If Option B works, prove `NoUnivBurgessR3` directly in Completeness.lean. If not, implement Option A: add `SetConsistent B` to `burgessR3` definition, audit cascade, and prove `NoUnivBurgessR3` trivially.
- [ ] **Task 1.4**: Run `lake build` and verify no regressions. Sorry count: 13 -> 12.

**Timing**: 2-4 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` line 152 -- close sorry
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- if Option A, modify `burgessR3` definition
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- cascade from definition change
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- cascade from definition change

**Verification**:
- Sorry at Completeness.lean:152 is closed
- `NoUnivBurgessR3` proved (not assumed)
- `lake build` passes
- No new sorries introduced by cascade

---

### Phase 2: Lemma 2.6 Case B (#1) and Lemma 2.7 Inconsistent Case (#3) [NOT STARTED]

**Goal**: Close sorry #1 (PointInsertion.lean:1977) and sorry #3 (PointInsertion.lean:2875) by removing the unnecessary case splits that Burgess never makes. These are formalization artifacts identified by the research: Burgess does not case-split on whether B is an MCS (#1) or whether {xi} union B is consistent (#3).

**Paper reference**: Burgess 2.6 (p.370-371) and 2.7 (p.372).

**Strategy for #1 (Case B)**: The sorry is in the pos sub-case when B is MCS. After the ClosedUnderDerivation cascade, this is now closable. Extract the maximality witness: since B is MCS and also ClosedUnderDerivation (from BurgessR3Maximal), DC(B union {beta}) must equal B for any beta in B (B is already maximal consistent). For beta not in B (the pos sub-case), since BurgessR3Maximal(A, B, C) and delta not in B, there exist beta0 in B and gamma0 in C with `(untl(beta0 AND delta, gamma0)).neg in A`. Use this witness with BX2 contrapositive to derive the contradiction needed for sorry #1.

**Strategy for #3 (inconsistent case)**: The sorry is in `lemma_2_7` when `{xi} union B` is inconsistent. Research confirms this is a formalization artifact -- Burgess's proof of 2.7 does not case-split on consistency. Instead, follow Burgess directly: the inconsistent case means `xi.neg in B` (since B is deductively closed). Since `xi not in B` (hypothesis) and B is ClosedUnderDerivation, we can derive the needed splitting via BurgessR3Maximal without checking consistency of {xi} union B. Alternatively, use Zorn variant accepting ClosedUnderDerivation seed (not requiring consistency).

**Tasks**:
- [ ] **Task 2.1**: Inspect goal state at sorry #1 (PointInsertion.lean:1977) with `lean_goal`. Understand available hypotheses in the Case B (B is MCS) branch.
- [ ] **Task 2.2**: Close sorry #1 by extracting maximality witness from DC(B union {beta}) + BX2 contrapositive. The ClosedUnderDerivation cascade already provides the needed infrastructure.
- [ ] **Task 2.3**: Inspect goal state at sorry #3 (PointInsertion.lean:2875) with `lean_goal`. Understand the inconsistent case branch.
- [ ] **Task 2.4**: Close sorry #3 by following Burgess directly -- either prove that `{xi} union B` is always consistent from the hypotheses (Option b from v60), or restructure to avoid the case split entirely using Zorn with ClosedUnderDerivation seed.
- [ ] **Task 2.5**: Run `lake build`. Verify PointInsertion.lean sorry count: 3 -> 1 (only sorry #2 remains).

**Timing**: 3-5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` lines 1977, 2875 -- close sorries #1 and #3

**Verification**:
- Sorries #1 and #3 both closed
- PointInsertion.lean sorry count: 3 -> 1
- `lake build` passes
- No new sorries introduced

---

### Phase 3: Lemma 2.7 Seed Consistency (#2) [NOT STARTED]

**Goal**: Close `lemma_2_7_seed_consistent` at PointInsertion.lean:2744 by implementing the full BX5+BX7+A3a chain per Burgess Section 2.7 (p.372). This is the single hardest sorry -- a 12-step axiomatic proof chain.

**Paper reference**: Burgess 2.7 (p.372). The proof reduces to showing the consistency of zeta = S(alpha, beta AND eta) AND beta AND xi AND U(gamma, beta), which Burgess proves using A5a (BX5), A7a (BX7), and A3a (BX13/enrichment).

**Convention mapping**: Our `untl(xi, eta)` = Burgess `U(eta, xi)`. In our code: xi = guard (first arg), eta = event (second arg). The seed has `{eta}` as singleton (Burgess xi = our eta = event) and `xi not in B` (Burgess eta = our xi = guard).

**Strategy** (following Burgess exactly):
1. Extract witness from `xi not in B` + `BurgessR3Maximal(A, B, C)`: get beta0 in B, gamma0 in C with `(untl(beta0 AND xi, gamma0)).neg in A`.
2. Apply BX5 (self_accum_until_mcs) to both Until formulas to get self-accumulated forms.
3. Apply BX7 (linear_until_mcs) for the three-way disjunction D1 or D2 or D3.
4. Eliminate D1: left_mono + right_mono produce `untl(beta0 AND xi, gamma0) in A`, contradicting witness.
5. Eliminate D2: right_mono to eta gives `untl(beta0 AND xi, eta)`. Apply BX14 (separation) with the witness negation, then BX13 (enrichment) and BX10.
6. Eliminate D3: similar BX14+BX13+BX10 chain.
7. All three disjuncts lead to contradiction with MCS consistency of A.

**Tasks**:
- [ ] **Task 3.1**: Verify the exact `Axiom.linear_until` form and confirm D1, D2, D3 structure using `lean_hover_info` on `linear_until_mcs`.
- [ ] **Task 3.2**: Implement Step 1: extract witness (beta0, gamma0) from BurgessR3Maximal + `xi not in B`.
- [ ] **Task 3.3**: Implement Steps 2-3: BX5 self-accumulation + BX7 three-way disjunction.
- [ ] **Task 3.4**: Implement Step 4: eliminate D1 via left_mono + right_mono -> contradiction.
- [ ] **Task 3.5**: Implement Step 5: eliminate D2 via right_mono to eta + BX14 separation + BX13 enrichment + BX10.
- [ ] **Task 3.6**: Implement Steps 6-7: eliminate D3 + assemble full proof.
- [ ] **Task 3.7**: Run `lake build`. Verify PointInsertion.lean sorry count: 1 -> 0 (fully sorry-free).

**Timing**: 6-10 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` line 2744 -- replace sorry with BX7 chain proof

**Verification**:
- Sorry #2 at line 2744 is closed
- `lemma_2_7_seed_consistent` fully proved
- PointInsertion.lean sorry count: 0
- `lake build` passes

---

### Phase 4: c2' Co-Construction for All 5 Elimination Types (#6-10) [NOT STARTED]

**Goal**: Close the 5 inline c2' sorries at CounterexampleElimination.lean lines 758, 796, 836, 874, 920 by constructing g-values (BurgessR3Maximal intermediate sets) for new adjacent pairs created by each elimination step.

**Paper reference**: Burgess 2.9-2.10 (p.373-374). Each elimination adds a point z, creating new adjacent pairs. C2' (the maximality invariant) requires BurgessR3Maximal on each adjacent pair.

**Architecture**: Five elimination types with mirror symmetry:
- C5 forward (line 758) / C5' backward (line 796): insert y beyond max/before min. g-value comes from `lemma_2_4` output B.
- C4 forward (line 836) / C4' backward (line 874): insert z between x,y. g-values come from `lemma_2_6_splitting` output (B', D, B'').
- Density insertion (line 920): insert z between adjacent x,y. Same `lemma_2_6_splitting` approach.

**Mirror optimization**: #6/#7 are mirrors, #8/#9 are mirrors. Prove one of each pair, then mechanically adapt.

**Tasks**:
- [ ] **Task 4.1**: Inspect EliminationResult type and the c2' sorry sites. Determine whether the g-value is already computed and just needs wiring to c2', or whether new g-value computation is needed.
- [ ] **Task 4.2**: Close c2' for C5 forward (#6, line 758). Capture B from `lemma_2_4` output. Wire `BurgessR3Maximal(f(x_max), B, f(y))` to c2' field.
- [ ] **Task 4.3**: Close c2' for C5' backward (#7, line 796). Mirror of Task 4.2.
- [ ] **Task 4.4**: Close c2' for C4 forward (#8, line 836). Use `lemma_2_6_splitting` on old adjacency to produce (B', D, B''). Set g-values for new pairs.
- [ ] **Task 4.5**: Close c2' for C4' backward (#9, line 874). Mirror of Task 4.4.
- [ ] **Task 4.6**: Close c2' for density insertion (#10, line 920). Same splitting approach as C4.
- [ ] **Task 4.7**: Verify old g-values for preserved adjacent pairs are correctly inherited.
- [ ] **Task 4.8**: Run `lake build`. Verify CounterexampleElimination.lean sorry count drops by 5 (from 7 to 2).

**Timing**: 6-10 hours

**Depends on**: 2, 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` lines 758, 796, 836, 874, 920 -- close c2' sorries
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- if EliminationResult needs g-value fields

**Verification**:
- Sorries #6-10 all closed
- CounterexampleElimination.lean sorry count: 7 -> 2 (C4 hard cases remain)
- All five elimination functions compile with populated g-values
- `lake build` passes

---

### Phase 5: C4/C4' Hard Cases (#4-5) [NOT STARTED]

**Goal**: Close the 2 standalone sorries at CounterexampleElimination.lean lines 413 (C4 forward hard case) and 511 (C4' backward hard case). These are the cases where `gamma in f(x)` AND `gamma in f(y)` (the "hard" case of Burgess Lemma 2.9, case n=m+1).

**Paper reference**: Burgess 2.9 (p.373), case n=m+1. When `U(gamma, delta) not in f(x)` and `gamma in f(y)`, the proof reduces to finding a z between x and y with `delta.neg in f(z)`.

**Strategy**: The c2' parameter (`h_c2'`) is now available from Phase 4. From c2', we have `BurgessR3Maximal(f(w), g(w,w_next), f(w_next))`. The hard case occurs when the C4 counterexample has `delta in f(x')` (the immediate successor of x). Then `gamma' = delta AND U(gamma, delta) in f(x')`. Using BX13 (enrichment) with `neg U(gamma, delta) in f(x)`, we get `neg U(gamma', delta) in f(x)`, reducing to the n=0 case. The `h_c2'` parameter provides the BurgessR3Maximal on the (x, x') pair needed for Lemma 2.6 splitting.

**Tasks**:
- [ ] **Task 5.1**: Inspect goal state at sorry #4 (line 413) with `lean_goal`. Verify that `h_c2'` is available in the function signature or needs to be added.
- [ ] **Task 5.2**: If `h_c2'` parameter is missing from `eliminate_C4_counterexample`, add it to the function signature and propagate to call sites.
- [ ] **Task 5.3**: Close C4 forward hard case (#4, line 413). Follow Burgess 2.9 case n=m+1: reduce to n=0 via enrichment, then apply Lemma 2.6 splitting using c2'.
- [ ] **Task 5.4**: Close C4' backward hard case (#5, line 511). Mirror of Task 5.3.
- [ ] **Task 5.5**: Run `lake build`. Verify CounterexampleElimination.lean is fully sorry-free.

**Timing**: 2-3 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` lines 413, 511 -- close C4/C4' hard cases

**Verification**:
- Sorries #4-5 both closed
- CounterexampleElimination.lean sorry count: 0
- `lake build` passes

---

### Phase 6: FUC/FSC Coherence and Final Validation (#11-12) [NOT STARTED]

**Goal**: Close sorries #11-12 at ChronicleToCountermodel.lean lines 621 (Forward Until Coherence) and 625 (Forward Since Coherence), then verify the entire completeness theorem is sorry-free.

**Paper reference**: Burgess 2.11 (p.375), truth lemma. The Until case: if `untl(phi, psi) in f(x)`, then by C5a there exists y > x with `psi in f(y)` and `phi in g(x,y)`. By C3, `phi in f(z)` for all z between x and y.

**Strategy for FUC (sorry #11)**: The forward Until coherence requires showing that for any `untl(phi, psi)` at a limit point x, there exists a witness y > x with the guard phi holding at all intermediate points:
1. From `untl(phi, psi) in limit_f(x)`, extract the finite stage n where the C5 witness y was added.
2. At stage n, the C5 elimination placed `psi in f_n(y)` and `phi in g_n(x,y)`.
3. By C3 invariant at the limit: `g(x,y) subset f(z)` for intermediate z, so `phi in f(z)`.
4. Transfer through the Cantor isomorphism to establish FUC.

**Mirror**: FSC (sorry #12) is the Since mirror of FUC.

**Tasks**:
- [ ] **Task 6.1**: Inspect goal state at sorry #11 (ChronicleToCountermodel.lean:621) with `lean_goal`. Understand the exact form of the FUC obligation.
- [ ] **Task 6.2**: Prove `limit_satisfies_c5_full` in ChronicleConstruction.lean -- the strengthened C5 with guard at intermediate points. Uses c2' invariant (now proved) and C3 at the limit.
- [ ] **Task 6.3**: Prove `limit_satisfies_c5'_full` (Since mirror of Task 6.2).
- [ ] **Task 6.4**: Close FUC sorry (#11, ChronicleToCountermodel.lean:621). Apply `limit_satisfies_c5_full` and transfer through Cantor isomorphism.
- [ ] **Task 6.5**: Close FSC sorry (#12, ChronicleToCountermodel.lean:625). Mirror of Task 6.4.
- [ ] **Task 6.6**: Final audit: run `#print axioms bx_completeness` and verify no `sorryAx`.
- [ ] **Task 6.7**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- verify only comment occurrences.
- [ ] **Task 6.8**: Run `grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- verify only comment occurrences.
- [ ] **Task 6.9**: Full `lake build` clean from scratch.

**Timing**: 4-6 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- add `limit_satisfies_c5_full`, `limit_satisfies_c5'_full`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` lines 621, 625 -- close FUC/FSC sorries

**Verification**:
- Sorries #11-12 both closed
- ChronicleToCountermodel.lean sorry count: 0
- `bx_completeness` has no `sorryAx` in its axioms
- `grep -rn "sorry" Chronicle/` returns only comment occurrences
- `grep -n "sorry" Completeness.lean` returns only comment occurrences
- Full `lake build` passes cleanly
- Total sorry count across all 4 files: 13 -> 0

---

## Testing & Validation

- [ ] `lake build` succeeds at every phase boundary (Phases 1-6)
- [ ] `#print axioms bx_completeness` -- no `sorryAx` after Phase 6
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- only comment occurrences
- [ ] `grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- only comment occurrences
- [ ] All 13 sorries systematically closed: 3 in PointInsertion, 7 in CounterexampleElimination, 2 in ChronicleToCountermodel, 1 in Completeness
- [ ] `irr_until` axiom NOT used anywhere
- [ ] No density or discreteness axioms added
- [ ] Convention alignment maintained (our `untl(guard, event)` = Burgess `U(event, guard)`)
- [ ] All elimination functions' g-field populated for new adjacent pairs
- [ ] FUC/FSC compile using `limit_satisfies_c5_full`

## Artifacts & Outputs

- `specs/107_chain_design_diagnostics_for_representation_theorem/plans/62_implementation-plan.md` (this file)
- `specs/107_chain_design_diagnostics_for_representation_theorem/summaries/62_execution-summary.md` (after Phase 6)
- Modified source files:
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (Phase 1)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (Phases 2-3)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (Phases 4-5)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (Phase 6)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (Phase 6)
  - Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (Phases 1, 4)

## Rollback/Contingency

- **Phase 1 (NoUnivBurgessR3)**: If Option B (prove from MCS properties) fails, Option A (add SetConsistent to burgessR3 definition) is the safe fallback. If Option A cascade is too wide, Option C (structural axiom) preserves all other work. Git commit before Phase 2 enables clean rollback.

- **Phase 2 (Case B + inconsistent case)**: If maximality extraction for Case B encounters unexpected proof obligations, the v60 plan had 3 resolution options for sorry #1 (the current strategy is the one confirmed viable by research). For sorry #3, if removing the case split exposes new issues, option (a) from v60 (add hypothesis) is the safe fallback.

- **Phase 3 (seed consistency)**: This is the hardest phase. If D2 elimination is blocked by non-derivability of `beta0 AND untl(beta0, gamma0) -> gamma0`, use the alternative path: right_mono to eta, then BX14 separation, then BX13+BX10. If all three disjuncts fail, consult Burgess 2.7 proof structure directly via `lean_goal` at each step.

- **Phase 4 (c2' co-construction)**: If modifying EliminationResult types is too invasive, prove c2' as a separate theorem by induction on the omega_chain. Implement simpler cases first (C5/C5') before C4/C4'/density.

- **Phase 5 (C4/C4' hard cases)**: Straightforward once c2' is available. If `h_c2'` propagation through function signatures is problematic, add it as an auxiliary field.

- **Phase 6 (FUC/FSC)**: If `limit_satisfies_c5_full` is unprovable via the staged approach, fall back to a direct argument using limit_g definition plus c2' invariant. Cantor isomorphism transfer is well-understood infrastructure.

- **General**: Commit after each phase boundary. Any phase can be reverted by checking out the prior commit.
