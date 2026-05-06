# Implementation Plan: Task #107 -- Burgess Chronicle Construction (Complete Sorry Elimination, Revised v55)

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [NOT STARTED]
- **Effort**: 28-46 hours
- **Dependencies**: None (self-contained within Chronicle/ and Completeness.lean)
- **Research Inputs**: reports/62_team-research.md, reports/60_full-audit.md, reports/55_team-research.md, reports/55_teammate-a-findings.md, reports/55_teammate-b-findings.md, reports/55_teammate-c-findings.md, reports/55_teammate-d-findings.md
- **Artifacts**: plans/55_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close all 15 remaining sorry sites across PointInsertion.lean (6 NoUnivBurgessR3 stubs), CounterexampleElimination.lean (7: 5 c2' + 2 C4 hard cases), and ChronicleToCountermodel.lean (2: FUC/FSC) to deliver a fully sorry-free completeness theorem for TM bimodal logic via the Burgess 1982 chronicle construction. Phases 1-3 from plan v62 are completed (NoUnivBurgessR3 definition fix, Lemma 2.6 Case B + inconsistent case, Lemma 2.7 seed consistency). This revised plan preserves those completed phases, adds a Phase 0 for ROADMAP documentation, incorporates team research findings about the EliminationResult infrastructure gap and C4/C4' complexity, and updates sorry counts and effort estimates. Definition of done: `#print axioms bx_completeness` shows no `sorryAx`; `lake build` succeeds; `grep -rn "sorry" Chronicle/` returns only comments.

### Research Integration

**Report 62 (team-research.md)**: Four-teammate analysis confirming 13 sorry sites at plan creation. Key findings: (1) NoUnivBurgessR3 is NOT a J0 theorem, requiring definition fix or semantic proof. (2) Sorries #1 and #3 are formalization artifacts from case splits Burgess never makes. (3) Mirror symmetry halves unique proof obligations (#4/#5, #6/#7, #8/#9, #11/#12). (4) c2' architecture gap is architectural (return type), not mathematical. (5) Lemma 2.7 seed consistency (#2) is hardest: 12-step BX5+BX7+A3a chain. (6) Case B (#1) is NOW closable after ClosedUnderDerivation cascade.

**Report 55 (team-research.md)**: Four-teammate research confirming incremental patching is correct over clean-break refactor. Key findings: (1) Actual sorry count is 15 (not 9): includes 6 NoUnivBurgessR3 stubs in PointInsertion.lean. (2) EliminationResult discards B/B'/B'' witnesses from Lemmas 2.4/2.6 (the `_B` pattern) -- must restructure before c2' can be closed. (3) C4/C4' hard cases are genuinely hard, need h_c2' parameter re-added. (4) NoUnivBurgessR3 IS provable via bot-guard argument: take beta=bot, get untl(bot,gamma) in A, BX10 gives F(bot), contradicts G(neg bot). (5) 80% of codebase is already Burgess-aligned; clean-break would risk breaking 3 recently-closed sorries.

### Prior Plan Reference

Plan v62 had 6 phases (25-41h). Phases 1-3 completed (NoUnivBurgessR3 definition fix, Lemma 2.6 Case B + inconsistent case, Lemma 2.7 seed consistency). PointInsertion.lean: 0 sorries on critical path (sorries #1-#3 closed), but 6 NoUnivBurgessR3 stubs remain. CounterexampleElimination.lean: 7 sorries (5 c2' + 2 C4 hard cases). ChronicleToCountermodel.lean: 2 sorries (FUC/FSC). Total critical-path sorries: 9 (unique obligations) or 15 (individual sorry sites, counting 6 NoUnivBurgessR3 stubs).

### Roadmap Alignment

- Task 107 is the primary completeness path (Chronicle construction)
- Advances: "4 sorry sites remain across 3 files" toward 0 (ROADMAP is stale; actual is 15 sorry sites)
- Closes the completeness theorem for TM bimodal logic (representation theorem goal)
- This revision documents the Burgess alignment migration path in ROADMAP.md

## Goals & Non-Goals

**Goals**:
- Update ROADMAP.md to document Burgess alignment migration ambition and current state
- Close 6 NoUnivBurgessR3 stubs in PointInsertion.lean via bot-guard argument
- Restructure EliminationResult to capture B/B'/B'' witnesses from Lemmas 2.4/2.6
- Close 5 c2' sorries in CounterexampleElimination.lean using captured witnesses
- Re-add h_c2' parameter to eliminate_C4_counterexample and close C4/C4' hard cases
- Close 2 FUC/FSC sorries in ChronicleToCountermodel.lean via limit_satisfies_c5_full
- Deliver fully sorry-free `bx_completeness` with no `sorryAx` dependency
- Follow Burgess 1982 exactly -- no unsound axioms, no shortcuts

**Non-Goals**:
- Add `irr_until` axiom (proven unsound for discrete orders)
- Add density or discreteness axioms (would restrict completeness theorem)
- Clean-break refactor of Chronicle/ (team research confirms incremental is lower risk)
- Restructure the overall chronicle construction architecture
- Generalize beyond D=Rat to arbitrary ordered groups
- Optimize proof term sizes or compilation speed
- Close BXCanonical sorries (task 109, separate)
- Unify R3Maximal and BurgessR3Maximal (post-completion cleanup)
- CUD-ify helper infrastructure (post-completion cleanup, documented in ROADMAP)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| NoUnivBurgessR3 bot-guard argument fails in Lean (missing F(bot) refutation lemma) | Blocks Phase 4 | Low | The argument is clean (Teammate A, high confidence). Fallback: add SetConsistent to burgessR3 definition |
| EliminationResult restructuring cascades into ChronicleConstruction.lean (700 lines sorry-free) | Build churn in Phase 5 | Medium | Implement incrementally per elimination type with `lake build` after each. Keep old sorries until all cases ready |
| h_c2' parameter re-addition cascades widely in eliminate_C4_counterexample | Blocks Phase 6 | Low | Parameter was previously present (removed in Phase 7 regression). Re-adding follows known path |
| C4/C4' hard cases require more than plumbing (genuinely hard mathematical proof) | Delays Phase 6 | Medium | Critic analysis (Teammate C) flags this. Time-box expanded to 4-8 hours. Follow Burgess 2.9 case n=m+1 exactly |
| FUC/FSC proof depends on entire upstream chain -- late-discovered issues | Late-phase blockers | Low | Each phase has independent verification. Commit at each boundary |
| Sorry #3 fix (B' = Set.univ for inconsistent xi) may have subtle soundness issue | Completeness correctness | Low | Teammate C flags concern. Build passes and ex falso argument is standard. Add assertion check if needed |
| ROADMAP update introduces incorrect information about sorry state | Documentation accuracy | Low | Cross-reference with grep output at time of writing |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 0 | -- |
| 2 | 1, 2, 3 | -- (already completed) |
| 3 | 4 | 0 |
| 4 | 5 | 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |

Phases within the same wave can execute in parallel.

---

### Phase 0: ROADMAP Update for Burgess Alignment Migration [COMPLETED]

**Goal**: Update specs/ROADMAP.md to document the ambition to migrate towards total alignment with Burgess 1982 definitions and approach. Record completed alignment work (Phases 1-3), remaining divergences, and migration steps embedded in subsequent phases.

**Tasks**:
- [ ] **Task 0.1**: Update the Chronicle sorry summary section in ROADMAP.md to reflect the current state: 15 sorry sites (6 NoUnivBurgessR3 in PI, 7 in CE, 2 in C2C), not the stale "4 sorry sites across 3 files."
- [ ] **Task 0.2**: Add a "Burgess Alignment Status" subsection under the Chronicle section documenting:
  - **Done**: BurgessR3Maximal CUD maximality fix (first conjunct changed from SetDeductivelyClosed to ClosedUnderDerivation), PointInsertion.lean sorry-free on critical path, Completeness.lean sorry-free
  - **Remaining divergences**: c1 still uses SetDeductivelyClosed (Burgess just needs CUD), two-track r-relation (rRelation vs burgessR -- Burgess has one), helper function signatures still use SDC instead of CUD, 6 NoUnivBurgessR3 stubs
  - **Migration steps**: NoUnivBurgessR3 closure (Phase 4), EliminationResult restructuring (Phase 5), h_c2' restoration (Phase 6)
- [ ] **Task 0.3**: Update the "Recommended Priority Order" and task cross-reference table to reflect current Phase status.
- [ ] **Task 0.4**: Run `lake build` to confirm no regressions from documentation changes.

**Timing**: 1-2 hours

**Depends on**: none

**Files to modify**:
- `specs/ROADMAP.md` -- update sorry counts, add Burgess alignment section, update task status

**Verification**:
- ROADMAP.md reflects accurate sorry counts (15 sites, 9 unique obligations)
- Burgess alignment section documents done/remaining/migration items
- `lake build` passes (no source changes, but confirm clean state)

---

### Phase 1: Resolve NoUnivBurgessR3 (#13) [COMPLETED]

**Goal**: Eliminate the root dependency sorry at Completeness.lean:152 where `NoUnivBurgessR3` (the property that `burgessR3(A, Set.univ, C)` never holds for any MCS A, C) is assumed without proof. This is the foundation on which the entire chronicle construction rests -- `dd_countermodel_chronicle` takes `NoUnivBurgessR3` as a parameter.

**Paper reference**: Implicit in Burgess 1982 Section 1.3 -- DCSs are consistent by definition (a DCS is "deductively closed" and "consistent" if bot is not a consequence). In Burgess's notation, `r(A, B, C)` requires B to be a DCS, and DCSs are consistent. `Set.univ` contains bot, so it is inconsistent and cannot be a DCS in Burgess's sense.

**Strategy**: Evaluate options in order of preference:

- **Option A (cleanest)**: Add `SetConsistent B` to the `burgessR3` definition, matching Burgess's implicit requirement that B is a DCS (and DCSs are consistent). Then `burgessR3(A, Set.univ, C)` is false because `Set.univ` is not consistent. NoUnivBurgessR3 becomes trivial. Requires cascading audit of all `burgessR3` users to supply the new `SetConsistent B` hypothesis.

- **Option B (least disruptive)**: Prove NoUnivBurgessR3 from the construction's properties: the chronicle uses Q (dense, totally ordered), where g(x,y) intervals always have intermediate points (for x < y, there exists z with x < z < y). On dense orders, `untl(bot, gamma) = (bot U gamma)` is unsatisfiable because the guard interval (x,y) is never empty. Since `burgessR3(A, Set.univ, C)` requires `untl(gamma, beta) in A` for all gamma in C and all beta in Set.univ, taking beta = bot gives `untl(gamma, bot) in A`, but `untl(gamma, bot)` requires F(bot) which contradicts MCS consistency of A. So NoUnivBurgessR3 follows from the fact that A is MCS.

- **Option C (fallback)**: Add NoUnivBurgessR3 as a structural axiom with semantic justification.

**Tasks**:
- [x] **Task 1.1**: Read the definition of `burgessR3` in ChronicleTypes.lean and all its usage sites. Determine whether `SetConsistent B` is already implied or easily added.
- [x] **Task 1.2**: Attempt Option B first -- check whether `burgessR3(A, Set.univ, C)` can be refuted from MCS properties of A alone. Result: NOT provable from J0. Counterexample on 2-point discrete order.
- [x] **Task 1.3**: Implemented Option A variant: reverted BurgessR3Maximal to SetDeductivelyClosed maximality, eliminating NoUnivBurgessR3 from ~450 sites.
- [x] **Task 1.4**: Run `lake build` and verify no regressions. Sorry count: 13 -> 12.

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

### Phase 2: Lemma 2.6 Case B (#1) and Lemma 2.7 Inconsistent Case (#3) [COMPLETED]

**Goal**: Close sorry #1 (PointInsertion.lean:1977) and sorry #3 (PointInsertion.lean:2875) by removing the unnecessary case splits that Burgess never makes. These are formalization artifacts identified by the research: Burgess does not case-split on whether B is an MCS (#1) or whether {xi} union B is consistent (#3).

**Paper reference**: Burgess 2.6 (p.370-371) and 2.7 (p.372).

**Strategy for #1 (Case B)**: The sorry is in the pos sub-case when B is MCS. After the ClosedUnderDerivation cascade, this is now closable. Extract the maximality witness: since B is MCS and also ClosedUnderDerivation (from BurgessR3Maximal), DC(B union {beta}) must equal B for any beta in B (B is already maximal consistent). For beta not in B (the pos sub-case), since BurgessR3Maximal(A, B, C) and delta not in B, there exist beta0 in B and gamma0 in C with `(untl(beta0 AND delta, gamma0)).neg in A`. Use this witness with BX2 contrapositive to derive the contradiction needed for sorry #1.

**Strategy for #3 (inconsistent case)**: The sorry is in `lemma_2_7` when `{xi} union B` is inconsistent. Research confirms this is a formalization artifact -- Burgess's proof of 2.7 does not case-split on consistency. Instead, follow Burgess directly: the inconsistent case means `xi.neg in B` (since B is deductively closed). Since `xi not in B` (hypothesis) and B is ClosedUnderDerivation, we can derive the needed splitting via BurgessR3Maximal without checking consistency of {xi} union B. Alternatively, use Zorn variant accepting ClosedUnderDerivation seed (not requiring consistency).

**Tasks**:
- [x] **Task 2.1**: Inspect goal state at sorry #1 (PointInsertion.lean:1968). Understood Case B (B is MCS) branch.
- [x] **Task 2.2**: Close sorry #1 via CUD maximality fix -- changed maximality clause from SetDeductivelyClosed to ClosedUnderDerivation, then derived contradiction from EFQ + left_mono + right_mono when guard b AND beta is inconsistent.
- [x] **Task 2.3**: Inspect goal state at sorry #3 (PointInsertion.lean:3156). Understood inconsistent case -- xi (guard) is itself inconsistent.
- [x] **Task 2.4**: Closed sorry #3. Changed BurgessR3Maximal first conjunct from SetDeductivelyClosed to ClosedUnderDerivation. Cascaded through RRelation.lean (extended Zorn return type), PointInsertion.lean (added h_B_dcs params). Closed via BurgessR3Maximal(A, Set.univ, D) with ex falso from inconsistent xi.
- [x] **Task 2.5**: `lake build` passes. PointInsertion.lean: 0 sorries on critical path.

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

### Phase 3: Lemma 2.7 Seed Consistency (#2) [COMPLETED]

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
- [x] **Task 3.1**: Verified linear_until_mcs form and D1, D2, D3 structure.
- [x] **Task 3.2**: Implemented Step 1: extract witness (beta0, gamma0) from BurgessR3Maximal CUD maximality.
- [x] **Task 3.3**: Implemented Steps 2-3: BX5 self-accumulation + BX7 three-way disjunction.
- [x] **Task 3.4**: Implemented Step 4: eliminate D1 via combine_imp_conj + left_mono + right_mono.
- [x] **Task 3.5**: Implemented Step 5: eliminate D2 via right_mono + BX13 enrichment.
- [x] **Task 3.6**: Implemented Steps 6-7: D3 survivor + BX13 iterated enrichment + BX10 F-extraction. h_key helper fully proved (~120 lines).
- [x] **Task 3.7**: Closed sorry #2. Defined l27_guard, l27_collect_guards, l27_c_event_list, l27_a_event_list, formula_and_left_cancel as private noncomputable defs. 10 membership lemmas + 100-line plumbing proof with 5-way case split. PointInsertion.lean sorry count: 2 -> 1.

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

### Phase 4: Close NoUnivBurgessR3 Stubs (6 sorries in PointInsertion.lean) [COMPLETED]

**Goal**: Close the 6 NoUnivBurgessR3 sorry stubs at PointInsertion.lean lines 178, 2717, 2719, 3596, 3598, 3686 by proving `no_univ_burgessR3 : SetMaximalConsistent A -> neg burgessR3 A Set.univ C` via the bot-guard argument identified by Teammate A.

**Paper reference**: Implicit in Burgess 1982. DCSs are consistent in Burgess's framework, so Set.univ (which contains bot) cannot be a valid DCS. Our formalization separates CUD from SDC, creating this gap.

**Strategy (bot-guard argument)**: From `burgessR3 A Set.univ C`, the condition `burgessRSet A Set.univ C` requires: for all beta in Set.univ and all gamma in C, `untl(beta, gamma) in A`. Taking beta = Formula.bot and any gamma: `untl(bot, gamma) in A`. Then BX10 (until_F) gives `F(gamma) in A`. But we can also take gamma = bot: `untl(bot, bot) in A`. BX10 gives `F(bot) in A`. However, `G(neg bot)` is a theorem (from temporal necessitation of `neg_bot_thm`), so `neg F(bot) in A` (since A is MCS and neg F(bot) = G(neg bot) is a theorem). This contradicts `F(bot) in A` by MCS consistency.

**Key property**: The argument depends ONLY on `SetMaximalConsistent A`, not on C. All 6 stubs can be closed by calling the same lemma with the appropriate MCS hypothesis.

**Tasks**:
- [ ] **Task 4.0**: Verify that the needed infrastructure exists: `until_implies_F_in_mcs` (BX10 at MCS level), temporal necessitation for `neg_bot_thm`, and the equivalence `neg (F phi) = G(neg phi)` at MCS level. Use `lean_local_search` and `lean_hover_info`.
- [ ] **Task 4.1**: Prove `no_univ_burgessR3` as a standalone theorem in PointInsertion.lean (or RRelation.lean): `theorem no_univ_burgessR3 (h_mcs : SetMaximalConsistent A) : neg burgessR3 A Set.univ C`.
- [ ] **Task 4.2**: Close the 6 sorry stubs at lines 178, 2717, 2719, 3596, 3598, 3686 by applying `no_univ_burgessR3` with the appropriate MCS hypothesis at each site.
- [ ] **Task 4.3**: Run `lake build`. Verify PointInsertion.lean has 0 sorry sites total.

**Timing**: 2-4 hours

**Depends on**: 0

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- add `no_univ_burgessR3` theorem, close 6 stubs
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` -- if theorem is better placed there

**Verification**:
- All 6 NoUnivBurgessR3 sorry stubs closed
- PointInsertion.lean: 0 sorries total (critical path + stubs)
- `no_univ_burgessR3` proved from `SetMaximalConsistent A` alone (no extra hypotheses)
- `lake build` passes
- No new sorries introduced

---

### Phase 5: EliminationResult Restructuring and c2' Co-Construction (#6-10) [NOT STARTED]

**Goal**: Close the 5 inline c2' sorries at CounterexampleElimination.lean lines 756, 794, 834, 872, 918 by restructuring EliminationResult to capture B/B'/B'' witnesses from Lemmas 2.4/2.6 and using them to construct g-values for new adjacent pairs created by each elimination step.

**Paper reference**: Burgess 2.9-2.10 (p.373-374). Each elimination adds a point z, creating new adjacent pairs. C2' (the maximality invariant) requires BurgessR3Maximal on each adjacent pair.

**Architecture**: Five elimination types with mirror symmetry:
- C5 forward (line 756) / C5' backward (line 794): insert y beyond max/before min. g-value comes from `lemma_2_4` output B (currently discarded as `_B`).
- C4 forward (line 834) / C4' backward (line 872): insert z between x,y. g-values come from `lemma_2_6_splitting` output (B', D, B'').
- Density insertion (line 918): insert z between adjacent x,y. Same `lemma_2_6_splitting` approach or Zorn construction.

**Critical prerequisite (from Teammate C analysis)**: The `_B` pattern in `eliminate_C5_counterexample` discards the B witness from `lemma_2_4`. This must be captured BEFORE c2' can be proved. Similarly, `eliminate_C4_counterexample` does not call `lemma_2_6_splitting` in the hard case -- the B'/B'' witnesses are never computed. EliminationResult must be modified to propagate these witnesses.

**Mirror optimization**: #6/#7 are mirrors, #8/#9 are mirrors. Prove one of each pair, then mechanically adapt.

**Tasks**:
- [ ] **Task 5.0**: Inspect EliminationResult type and the c2' sorry sites. Map out exactly which fields carry g-value information and which callers depend on EliminationResult. Determine the minimal type change needed.
- [ ] **Task 5.1**: Modify `eliminate_C5_counterexample` to capture B from `lemma_2_4` output (change `_B` to `B`). Update the returned chronicle's g-function to use B for the new adjacent pair (x_max, y_new). Wire `BurgessR3Maximal(f(x_max), B, f(y_new))` to the c2' field.
- [ ] **Task 5.2**: Close c2' for C5 forward (#6, line 756). Verify `lake build`.
- [ ] **Task 5.3**: Close c2' for C5' backward (#7, line 794). Mirror of Task 5.2. Verify `lake build`.
- [ ] **Task 5.4**: Modify `eliminate_C4_counterexample` to call `lemma_2_6_splitting` in the relevant case paths and capture B', D, B''. Update g-function for new pairs (w, z) and (z, w_next).
- [ ] **Task 5.5**: Close c2' for C4 forward (#8, line 834). Verify `lake build`.
- [ ] **Task 5.6**: Close c2' for C4' backward (#9, line 872). Mirror of Task 5.5. Verify `lake build`.
- [ ] **Task 5.7**: Close c2' for density insertion (#10, line 918). Use `lemma_2_6_splitting` or Zorn on the split pair. Verify `lake build`.
- [ ] **Task 5.8**: Verify old g-values for preserved adjacent pairs are correctly inherited via `g_agrees`.
- [ ] **Task 5.9**: Run `lake build`. Verify CounterexampleElimination.lean sorry count drops by 5 (from 7 to 2).

**Timing**: 8-12 hours

**Depends on**: 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` lines 756, 794, 834, 872, 918 -- close c2' sorries; modify elimination function signatures
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- if EliminationResult needs g-value fields
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- if omega_chain callers need updating

**Verification**:
- Sorries #6-10 all closed
- CounterexampleElimination.lean sorry count: 7 -> 2 (C4 hard cases remain)
- All five elimination functions compile with populated g-values for new adjacent pairs
- Old adjacent pair g-values correctly inherited
- `lake build` passes

---

### Phase 6: C4/C4' Hard Cases (#4-5) [NOT STARTED]

**Goal**: Close the 2 standalone sorries at CounterexampleElimination.lean lines 412 (C4 forward hard case) and 510 (C4' backward hard case). These are the cases where `gamma in f(x)` AND `gamma in f(y)` (the "hard" case of Burgess Lemma 2.9, case n=m+1).

**Paper reference**: Burgess 2.9 (p.373), case n=m+1. When `U(gamma, delta) not in f(x)` and `gamma in f(y)`, the proof reduces to finding a z between x and y with `delta.neg in f(z)`.

**Critical prerequisite (from Teammate C analysis)**: The `h_c2'` parameter was REMOVED from `eliminate_C4_counterexample` in an earlier phase (design regression). It must be re-added to the function signature before these sorries can be closed. The c2' parameter provides `BurgessR3Maximal(f(w_max), g(w_max, w_next), f(w_next))` for the adjacent pair at the rightmost counterexample point, which is needed for the Lemma 2.6 splitting argument.

**Strategy**: Once h_c2' is re-added:
1. From c2', obtain `BurgessR3Maximal(f(w), g(w,w_next), f(w_next))` for the adjacent pair containing the counterexample.
2. The hard case occurs when the C4 counterexample has `delta in f(x')` (the immediate successor of x).
3. Then `gamma' = delta AND U(gamma, delta) in f(x')`. Using BX13 (enrichment) with `neg U(gamma, delta) in f(x)`, reduce to the n=0 case.
4. Apply Lemma 2.6 splitting using the c2' BurgessR3Maximal fact.

**Tasks**:
- [ ] **Task 6.1**: Inspect goal state at sorry #4 (line 412) with `lean_goal`. Verify that `h_c2'` is NOT available in the current function signature.
- [ ] **Task 6.2**: Re-add `h_c2'` parameter to `eliminate_C4_counterexample` and `eliminate_potential_counterexample` signatures. Propagate to all call sites.
- [ ] **Task 6.3**: Close C4 forward hard case (#4, line 412). Follow Burgess 2.9 case n=m+1: extract BurgessR3Maximal from h_c2' for the adjacent pair at w_max, apply enrichment to reduce iteration count, then apply Lemma 2.6 splitting.
- [ ] **Task 6.4**: Close C4' backward hard case (#5, line 510). Mirror of Task 6.3.
- [ ] **Task 6.5**: Run `lake build`. Verify CounterexampleElimination.lean is fully sorry-free.

**Timing**: 4-8 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` lines 412, 510 -- close C4/C4' hard cases; re-add h_c2' parameter
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- if caller signatures change

**Verification**:
- Sorries #4-5 both closed
- CounterexampleElimination.lean sorry count: 0
- `h_c2'` parameter properly threaded through all call sites
- `lake build` passes

---

### Phase 7: FUC/FSC Coherence and Final Validation (#11-12) [NOT STARTED]

**Goal**: Close sorries #11-12 at ChronicleToCountermodel.lean lines 611 (Forward Until Coherence) and 615 (Forward Since Coherence), then verify the entire completeness theorem is sorry-free.

**Paper reference**: Burgess 2.11 (p.375), truth lemma. The Until case: if `untl(phi, psi) in f(x)`, then by C5a there exists y > x with `psi in f(y)` and `phi in g(x,y)`. By C3, `phi in f(z)` for all z between x and y.

**Strategy for FUC (sorry #11)**: The forward Until coherence requires showing that for any `untl(phi, psi)` at a limit point x, there exists a witness y > x with the guard phi holding at all intermediate points:
1. From `untl(phi, psi) in limit_f(x)`, extract the finite stage n where the C5 witness y was added.
2. At stage n, the C5 elimination placed `psi in f_n(y)` and `phi in g_n(x,y)`.
3. By C3 invariant at the limit: `g(x,y) subset f(z)` for intermediate z, so `phi in f(z)`.
4. Transfer through the Cantor isomorphism to establish FUC.

**Mirror**: FSC (sorry #12) is the Since mirror of FUC.

**Dependency note**: FUC/FSC are the MOST DEPENDENT sorries (Teammate C). They require everything upstream: NoUnivBurgessR3 closed (Phase 4), c2' established at all finite stages (Phase 5), h_c2' available for C4/C4' (Phase 6). Do not attempt until all upstream phases are complete.

**Tasks**:
- [ ] **Task 7.1**: Inspect goal state at sorry #11 (ChronicleToCountermodel.lean:611) with `lean_goal`. Understand the exact form of the FUC obligation.
- [ ] **Task 7.2**: Prove `limit_satisfies_c5_full` in ChronicleConstruction.lean -- the strengthened C5 with guard at intermediate points. Uses c2' invariant (now proved) and C3 at the limit.
- [ ] **Task 7.3**: Prove `limit_satisfies_c5'_full` (Since mirror of Task 7.2).
- [ ] **Task 7.4**: Close FUC sorry (#11, ChronicleToCountermodel.lean:611). Apply `limit_satisfies_c5_full` and transfer through Cantor isomorphism.
- [ ] **Task 7.5**: Close FSC sorry (#12, ChronicleToCountermodel.lean:615). Mirror of Task 7.4.
- [ ] **Task 7.6**: Final audit: run `#print axioms bx_completeness` and verify no `sorryAx`.
- [ ] **Task 7.7**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- verify only comment occurrences.
- [ ] **Task 7.8**: Run `grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- verify only comment occurrences.
- [ ] **Task 7.9**: Full `lake build` clean from scratch.

**Timing**: 4-6 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- add `limit_satisfies_c5_full`, `limit_satisfies_c5'_full`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` lines 611, 615 -- close FUC/FSC sorries

**Verification**:
- Sorries #11-12 both closed
- ChronicleToCountermodel.lean sorry count: 0
- `bx_completeness` has no `sorryAx` in its axioms
- `grep -rn "sorry" Chronicle/` returns only comment occurrences
- `grep -n "sorry" Completeness.lean` returns only comment occurrences
- Full `lake build` passes cleanly
- Total sorry count across all critical-path files: 15 -> 0

---

## Testing & Validation

- [ ] `lake build` succeeds at every phase boundary (Phases 0-7)
- [ ] `#print axioms bx_completeness` -- no `sorryAx` after Phase 7
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- only comment occurrences
- [ ] `grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- only comment occurrences
- [ ] All 15 sorry sites systematically closed: 6 NoUnivBurgessR3 in PointInsertion, 5 c2' + 2 C4 hard cases in CounterexampleElimination, 2 FUC/FSC in ChronicleToCountermodel
- [ ] `irr_until` axiom NOT used anywhere
- [ ] No density or discreteness axioms added
- [ ] Convention alignment maintained (our `untl(guard, event)` = Burgess `U(event, guard)`)
- [ ] All elimination functions' g-field populated for new adjacent pairs
- [ ] FUC/FSC compile using `limit_satisfies_c5_full`
- [ ] EliminationResult captures B/B'/B'' witnesses from Lemmas 2.4/2.6
- [ ] h_c2' parameter available in eliminate_C4_counterexample signature

## Artifacts & Outputs

- `specs/107_chain_design_diagnostics_for_representation_theorem/plans/55_implementation-plan.md` (this file)
- `specs/107_chain_design_diagnostics_for_representation_theorem/summaries/55_execution-summary.md` (after Phase 7)
- Modified source files:
  - `specs/ROADMAP.md` (Phase 0)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (Phases 1-4)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (Phases 5-6)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (Phase 7)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (Phase 7)
  - Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (Phases 4-5)
  - Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (Phase 4)
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (Phase 1, already done)

## Rollback/Contingency

- **Phase 0 (ROADMAP update)**: Documentation only, no source changes. No rollback needed.

- **Phase 1-3 (completed)**: Already committed. Git history preserves rollback points.

- **Phase 4 (NoUnivBurgessR3 stubs)**: If the bot-guard argument fails in Lean (missing F(bot) refutation lemma), fallback: add `SetConsistent B` to `burgessR3` definition (Option A from v62 plan). This triggers a cascade but is known to work. If Option A cascade is too wide, Option C (structural axiom) preserves all other work.

- **Phase 5 (c2' co-construction)**: If modifying EliminationResult types is too invasive and breaks ChronicleConstruction.lean, prove c2' as a separate theorem by induction on the omega_chain (avoiding structural changes). Implement simpler cases first (C5/C5') before C4/C4'/density. Each elimination type is independently committable.

- **Phase 6 (C4/C4' hard cases)**: If re-adding h_c2' propagation through function signatures is problematic, add it as an auxiliary field in EliminationResult or as a separate parameter passed through ChronicleConstruction. If the mathematical proof (Burgess 2.9 case n=m+1) requires infrastructure not yet available, time-box at 8 hours and mark PARTIAL.

- **Phase 7 (FUC/FSC)**: If `limit_satisfies_c5_full` is unprovable via the staged approach, fall back to a direct argument using limit_g definition plus c2' invariant. Cantor isomorphism transfer is well-understood infrastructure.

- **General**: Commit after each phase boundary. Any phase can be reverted by checking out the prior commit.
