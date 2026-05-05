# Implementation Plan: Task #107 — Burgess Chronicle Construction (Complete Sorry Elimination)

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [NOT STARTED]
- **Effort**: 30-42 hours
- **Dependencies**: None (self-contained within Chronicle/)
- **Research Inputs**: reports/60_full-audit.md, reports/59_team-research.md, handoffs/phase3-convention-fix.md
- **Artifacts**: plans/53_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close all 12 remaining sorries across PointInsertion.lean (3), CounterexampleElimination.lean (7), and ChronicleToCountermodel.lean (2) to deliver a fully sorry-free Burgess chronicle construction and representation theorem for TM bimodal logic. The build is currently broken by a type mismatch at PointInsertion.lean:2894 (sorry #3 in the `lemma_2_7` inconsistent case) that must be fixed first. After restoring the build, the plan systematically closes every sorry in strict dependency order: infrastructure (BX7 MCS wrapper), PointInsertion lemma sorries (2.6 pos sub-case, 2.7 seed consistency, 2.7 inconsistent case), CounterexampleElimination c2' co-construction and C4 hard cases, and finally ChronicleToCountermodel FUC/FSC coherence. Definition of done: `#print axioms dd_countermodel_chronicle` shows no `sorryAx`; `lake build` succeeds; `grep -rn "sorry" Chronicle/` returns only comments.

### Research Integration

**Report 60 (full-audit.md)**: Complete sorry inventory identifying all 12 sites with precise file/line/function locations. Convention audit confirming zero remaining misalignments after the Phase 3 convention fix. Build error diagnosis at PointInsertion.lean:2894 with restructuring fix. Infrastructure audit: only `linear_until_mcs` (BX7 MCS wrapper) is missing; all other BX wrappers are sorry-free. Recommended order of operations providing the dependency chain skeleton.

**Report 59 (team-research.md)**: Unanimous findings across 4 teammates: (1) the inconsistent case split is a formalization artifact from `SetDeductivelyClosed` requiring consistency while Burgess's DCS does not, (2) `irr_until` axiom is unsound for discrete orders and must never be used, (3) Burgess's DCS does not require consistency, (4) Phases 3-7 of the prior plan are independent of Phase 2. Teammate A's claim about the event-position argument for `untl(bot, gamma_hat)` needs verification but provides a potential shortcut.

**Handoff (phase3-convention-fix.md)**: Documents the xi/eta convention swap applied to `lemma_2_7_seed`, `lemma_2_7_seed_consistent`, and `lemma_2_7`. Our `untl(xi, eta)` = Burgess `U(eta, xi)` (guard/event swapped). The fix UNBLOCKS the BX7 three-way argument by ensuring the combined guard contains xi. Also documents the D2 elimination subtlety: `beta0 AND untl(beta0, gamma0) -> gamma0` is NOT directly derivable, requiring an alternative D2 elimination strategy.

### Prior Plan Reference

Plan 57 had 7 phases (24-34h estimated). Phase 1 (definition revert to `SetDeductivelyClosed D`) is COMPLETED and verified. Phase 2 reached PARTIAL: neg sub-case completed via `burgess_zeta_consistent`, pos sub-case blocked at sorry #1. Plan 57's MCS case-split strategy (Case A: B not MCS, Case B: B is MCS) for the pos sub-case is retained as the primary approach. Effort lessons: (a) convention alignment was critical (now resolved by handoff), (b) D2 elimination in BX7 three-way needs careful verification at the Lean goal level, (c) c2' co-construction across 5 elimination types is the highest-effort single block. The older plan 53 had 11 sub-phases (37-47h) with more granular Phase 4 decomposition; this plan consolidates the c2' work into two phases while keeping total effort realistic.

### Roadmap Alignment

No ROADMAP.md found.

## Goals & Non-Goals

**Goals**:
- Fix the build error at PointInsertion.lean:2894 (BLOCKING, must be first)
- Add `linear_until_mcs` (BX7 MCS wrapper) as prerequisite infrastructure
- Close sorry #1 (Lemma 2.6 pos sub-case) via plan 57's MCS case-split strategy
- Close sorry #2 (Lemma 2.7 seed consistency) via BX5+BX7+BX14+BX13+BX10 chain per Burgess p.372
- Close sorry #3 (Lemma 2.7 inconsistent case) by proof or hypothesis addition
- Close sorries #6-10 (c2' maintenance for all 5 elimination types) with g-value co-construction
- Close sorries #4-5 (C4/C4' hard cases) via BurgessR3 bridging from c2'
- Close sorries #11-12 (FUC/FSC coherence) via `limit_satisfies_c5_full`
- Deliver fully sorry-free `dd_countermodel_chronicle`
- Follow Burgess 1982 exactly -- no unsound axioms, no shortcuts

**Non-Goals**:
- Add `irr_until` axiom (proven unsound for discrete orders by team research)
- Add density or discreteness axioms (would restrict completeness theorem)
- Skip or defer any sorry (user directive: close ALL 12 systematically)
- Introduce any axiom not in Burgess's base system J0
- Restructure the overall chronicle construction architecture
- Generalize beyond D=Rat to arbitrary ordered groups
- Optimize proof term sizes or compilation speed

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Build error fix introduces new complications | Blocks all work | Low | Restructuring is purely syntactic (move `by_cases` outside `have` block). Inspect with `lean_goal` if unexpected |
| MCS case-split in Phase 3 has edge cases (B not DCS, B inconsistent) | Blocks Phase 3 | Low | B is always DCS (from `BurgessR3Maximal` definition). Case A/B are exhaustive by classical logic |
| D2 elimination in BX7 three-way requires non-obvious derivation | Blocks Phase 4 | Medium | Handoff documents this. Fallback: eliminate D1+D2 jointly by reducing both to `untl(beta0 AND xi, gamma0)` via left_mono, or use BX14 separation on D2 |
| Lemma 2.7 inconsistent case (`{xi} union B` inconsistent) needs hypothesis | Blocks Phase 5, cascades | Medium | Three options: (a) add precondition, (b) prove from hypotheses, (c) case split at call site. Option (a) is safest and cleanest |
| c2' co-construction requires modifying EliminationResult signatures | Build churn | Medium | Implement incrementally with `lake build` after each case. Keep old g-value sorries until all cases ready |
| FUC/FSC proof depends on entire upstream chain | Late-discovered issues cascade | Low | Each phase has independent verification. Commit at each boundary for rollback |
| `linear_until_mcs` wrapper has unexpected proof obligations from BX7 axiom form | Delays Phase 2 | Low | Pattern follows existing wrappers. BX7 axiom has sorry-free soundness proof |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3, 4 | 2 |
| 4 | 5 | 3, 4 |
| 5 | 6 | 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |

Phases 3 and 4 can execute in parallel (both depend only on Phase 2). All other phases are sequential on the critical path.

---

### Phase 1: Fix Build Error [NOT STARTED]

**Goal**: Restore the build to a passing state (with sorries) by fixing the type mismatch at PointInsertion.lean:2894 where a `SetConsistent {xi}` is produced inside a goal expecting `False`.

**Tasks**:
- [ ] **Task 1.1**: Restructure the `by_cases h_cons : SetConsistent ({xi} union B)` block at lines 2893-2922. Move the `by_cases` OUTSIDE the `have h_xi_consistent` block so that in the consistent case, `h_xi_consistent` is derived via `SetConsistent_of_subset Set.subset_union_left h_cons`, and the rest of the proof proceeds normally. In the inconsistent case, the proof reaches `sorry` (sorry #3) but compiles correctly.
- [ ] **Task 1.2**: Run `lake build` and verify 0 errors (sorries allowed). Confirm the type mismatch at line 2894 is resolved.
- [ ] **Task 1.3**: Verify sorry count remains at 12 (no new sorries introduced, none removed).

**Timing**: 30-60 minutes

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` lines 2581-2922 -- restructure by_cases block

**Verification**:
- `lake build` passes (0 errors)
- The type mismatch at line 2894 is resolved
- Sorry count remains at 12

---

### Phase 2: Add `linear_until_mcs` Infrastructure [NOT STARTED]

**Goal**: Implement the BX7 MCS-level wrapper `linear_until_mcs`, the only missing infrastructure piece identified by the audit (report 60 Section 4).

**Tasks**:
- [ ] **Task 2.1**: Verify the exact `Axiom.linear_until` statement in the codebase. Determine the parameter order and disjunction form. The expected form is: `untl(phi, psi) AND untl(chi, theta) -> untl(phi AND chi, psi AND theta) OR untl(phi AND chi, psi AND chi) OR untl(phi AND chi, phi AND theta)`.
- [ ] **Task 2.2**: Implement `linear_until_mcs` near line 189 of PointInsertion.lean (adjacent to `self_accum_until_mcs`, `separation_until_mcs`, etc.). Proof pattern: use `h_mcs.deductively_closed` or the MCS disjunction lemma to lift the axiom-level derivation to MCS membership.
- [ ] **Task 2.3**: If a Since analogue `linear_since_mcs` is needed (check `Axiom.linear_since` or BX7'), implement it alongside.
- [ ] **Task 2.4**: Run `lake build` and verify no regressions. The new wrapper must compile without sorry.

**Timing**: 1-1.5 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- add `linear_until_mcs` near existing MCS wrappers

**Verification**:
- `linear_until_mcs` compiles without sorry
- `lake build` passes
- Wrapper correctly lifts BX7 axiom to MCS-level membership with three-way disjunction

---

### Phase 3: Lemma 2.6 -- Close Sorry #1 (Pos Sub-case) [NOT STARTED]

**Goal**: Close the sorry at PointInsertion.lean:1891 in `burgess_D0_finite_subset_consistent_incons` using plan 57's MCS case-split strategy.

**Paper reference**: Burgess Section 2.6, p.370-371.

**Root cause**: In the inconsistent sub-case (`beta.neg in B`), the conjunction `b AND beta` is propositionally false. Left_mono from bot gives ALL `untl(r, gamma_hat) in A` for any r, so BX14 can never fire in the pos sub-case.

**Strategy**: Case-split on `SetMaximalConsistent B`:

- **Case A (B not MCS)**: B is a DCS (from BurgessR3Maximal) but not MCS, so there exists delta' not in B with `{delta'} union B` consistent. Apply `BurgessR3Maximal_extension_fails` with delta' to get witness `(beta0, gamma0)` with `(untl(beta0 AND delta', gamma0)).neg in A`. Ensure gamma0 participates in c_list so gamma_hat implies gamma0. Then in the pos sub-case: left_mono from bot gives `untl(beta0 AND delta', gamma_hat) in A`, while right_mono contrapositive (from `G(gamma_hat -> gamma0)` + witness negation) gives `(untl(beta0 AND delta', gamma_hat)).neg in A` -- contradicting MCS consistency of A.

- **Case B (B is MCS)**: B itself serves as the splitting MCS D. Since `beta.neg in B` and B is MCS, set D = B. Construct B' via `burgessR3Maximal_extension_exists` for `burgessR3(A, B', B)` and B'' for `burgessR3(B, B'', C)`. Return the splitting triple `(B', B, B'')` directly, bypassing D0 seed construction entirely.

**Tasks**:
- [ ] **Task 3.1**: Inspect the exact proof state at sorry #1 (line 1891) using `lean_goal`. Understand the goal type and all available hypotheses.
- [ ] **Task 3.2**: Implement the `by_cases h_mcs_B : SetMaximalConsistent B` case split within the pos sub-case.
- [ ] **Task 3.3**: Implement Case B (B is MCS) -- the fast path. Verify that `burgessR3Maximal_extension_exists` can construct B' and B'' when D = B.
- [ ] **Task 3.4**: Implement Case A (B not MCS) -- extract delta' not in B with `{delta'} union B` consistent. Apply `BurgessR3Maximal_extension_fails` for the witness. Derive contradiction via left_mono + right_mono contrapositive.
- [ ] **Task 3.5**: Handle edge cases. Verify that `not SetMaximalConsistent B` provides a usable delta' given that B is a DCS (hence consistent). The non-MCS condition means there exists phi where `phi not in B` and `phi.neg not in B`, giving us delta' = phi with `{phi} union B` consistent.
- [ ] **Task 3.6**: Run `lake build`. Verify PointInsertion.lean sorry count drops by 1.

**Timing**: 2-3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` lines 1825-1891 -- restructure the pos sub-case with MCS case-split

**Verification**:
- Sorry #1 at line 1891 is closed
- `lake build` passes
- PointInsertion.lean sorry count: 3 -> 2
- `irr_until` axiom NOT used

---

### Phase 4: Lemma 2.7 -- Close Sorry #2 (Seed Consistency via BX7 Three-Way) [NOT STARTED]

**Goal**: Close `lemma_2_7_seed_consistent` at PointInsertion.lean:2483 by implementing the full BX5+BX7+BX14+BX13+BX10 chain per Burgess Section 2.7, p.372.

**Paper reference**: Burgess Section 2.7, p.372.

**Convention reminder**: Our `untl(xi, eta)` = Burgess `U(eta, xi)`. In our code: xi = guard (first arg), eta = event (second arg). The seed has `{eta}` as singleton (Burgess xi = our eta = event) and `xi not in B` (Burgess eta = our xi = guard). The handoff confirms this convention is now correctly aligned.

**Strategy** (10-step Burgess chain):
1. **Extract witness**: From `xi not in B` + `BurgessR3Maximal(A, B, C)`, apply `BurgessR3Maximal_neg_or_ext_fails`. Since xi not in B, get `beta0 in B, gamma0 in C` with `(untl(beta0 AND xi, gamma0)).neg in A`. (If xi.neg in B, handle separately -- this feeds into sorry #3.)
2. **BX5 on `untl(xi, eta)`**: `untl(xi AND untl(xi, eta), eta) in A`.
3. **BX5 on `untl(beta0, gamma0)`**: `untl(beta0 AND untl(beta0, gamma0), gamma0) in A`.
4. **BX7** (`linear_until_mcs`): three-way disjunction D1 or D2 or D3.
5. **Eliminate D1**: D1 = `untl(g1 AND g2, eta AND gamma0)` where g1 = `xi AND untl(xi,eta)`, g2 = `beta0 AND untl(beta0,gamma0)`. Apply left_mono: `g1 AND g2 -> beta0 AND xi` (since g2 contains beta0, g1 contains xi). Apply right_mono: `eta AND gamma0 -> gamma0`. Result: `untl(beta0 AND xi, gamma0) in A`. Contradiction with witness.
6. **Eliminate D2**: D2 = `untl(g1 AND g2, eta AND g2)`. Left_mono: `g1 AND g2 -> beta0 AND xi`. Right_mono: `eta AND g2 -> gamma0` ONLY IF `g2 -> gamma0`, i.e., `beta0 AND untl(beta0, gamma0) -> gamma0` -- this is NOT derivable. **Alternative**: right_mono `eta AND g2 -> eta` gives `untl(beta0 AND xi, eta)`. Then apply BX14 separation with `(untl(beta0 AND xi, gamma0)).neg in A` to derive `untl(beta0 AND xi, eta AND (beta0 AND xi).neg) in A`. Continue with BX13 and BX10.
7. **D3 survives**: D3 = `untl(g1 AND g2, g1 AND gamma0)`. This has xi in the event (via g1). Apply right_mono to reduce, then BX14 separation, BX13 iterated enrichment for snce-formulas, BX10 for F(event).
8. **Show event implies all 5 seed components**: B-elements via b-conjunction in guard, eta from event component, untl-formulas via mono, snce-formulas via mono, snce(beta AND xi, alpha) via mono with guard containing xi.
9. **Contradiction**: `derivation_from_implied` + `consistent_of_F_mem` + `inconsistent_singleton_false`.

**Tasks**:
- [ ] **Task 4.1**: Verify `Axiom.linear_until` output form and confirm D1, D2, D3 structure matches the strategy above. Adjust if BX7 has different disjunct ordering.
- [ ] **Task 4.2**: Implement Step 1: extract witness `(beta0, gamma0)` with `(untl(beta0 AND xi, gamma0)).neg in A`. Handle the `xi.neg in B` sub-case by showing it contradicts the hypotheses or deferring to sorry #3.
- [ ] **Task 4.3**: Implement Steps 2-3: BX5 self-accumulation on both Until formulas using `self_accum_until_mcs`.
- [ ] **Task 4.4**: Implement Step 4: apply `linear_until_mcs` to get the three-way disjunction. Use MCS disjunction properties to case-split.
- [ ] **Task 4.5**: Implement Step 5: eliminate D1 via left_mono + right_mono producing `untl(beta0 AND xi, gamma0) in A`, contradicting witness.
- [ ] **Task 4.6**: Implement Step 6: eliminate D2. First try the full right_mono path. If `beta0 AND untl(beta0, gamma0) -> gamma0` is not derivable, use the alternative path: right_mono to eta, then BX14 separation, then BX13+BX10.
- [ ] **Task 4.7**: Implement Steps 7-9: work with surviving D3. Apply BX14 separation, BX13 enrichment, BX10 extraction, show event implies all 5 seed components, derive contradiction.
- [ ] **Task 4.8**: Assemble the full proof and close `lemma_2_7_seed_consistent`. Run `lake build`.

**Timing**: 2-3 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` line 2483 -- replace sorry with full BX7 chain proof

**Verification**:
- Sorry #2 at line 2483 is closed
- `lemma_2_7` body still compiles
- `lake build` passes
- PointInsertion.lean sorry count: 2 -> 1 (only sorry #3 remains)

---

### Phase 5: Lemma 2.7 -- Close Sorry #3 (Inconsistent Case) [NOT STARTED]

**Goal**: Close the sorry for the case where `{xi} union B` is inconsistent in `lemma_2_7` (PointInsertion.lean, restructured by Phase 1). Make PointInsertion.lean fully sorry-free.

**Analysis**: When `{xi} union B` is inconsistent, `xi.neg in B` (since B is deductively closed). The question is whether `untl(xi, eta) in A` and `BurgessR3Maximal(A, B, C)` with `xi not in B` can coexist with `xi.neg in B`. Under open-guard semantics on discrete orders, `untl(xi, eta) in A` is possible even when `xi` is inconsistent (the guard interval can be empty). So this case CAN arise mathematically.

**Strategy** (try in order):
1. **Option (b) -- prove consistency from hypotheses**: Attempt to show that `BurgessR3Maximal(A, B, C)` with `untl(xi, eta) in A` and `xi not in B` implies `{xi} union B` is consistent. If `xi.neg in B`, then since `untl(xi, eta) in A` and A is MCS, we have `(untl(xi, eta)).neg not in A`. But `xi.neg in B` with `BurgessR3(A, B, C)` means every formula derivable from `B union {xi.neg}` is in B -- this is just DCS closure. Check whether `xi.neg in B` leads to `(untl(xi, eta)).neg in A` via the R3 relation, which would give the contradiction.
2. **Option (a) -- add hypothesis**: If option (b) fails, add `SetConsistent ({xi} union B)` as a precondition to `lemma_2_7`. Then the inconsistent case is eliminated. Update the call site in `eliminate_C5_counterexample` to supply this precondition, handling the `xi.neg in B` case separately there.
3. **Option (c) -- case split at call site**: If the call site cannot easily supply the precondition, handle `xi.neg in B` directly at the C5 elimination level without invoking `lemma_2_7`.

**Tasks**:
- [ ] **Task 5.1**: Investigate option (b). Check with `lean_goal` what hypotheses are available in the inconsistent case. Attempt to derive a contradiction from `xi.neg in B` using the BurgessR3 relation, MCS properties of A, and `untl(xi, eta) in A`.
- [ ] **Task 5.2**: If option (b) fails, locate all call sites of `lemma_2_7` (expected: `eliminate_C5_counterexample` in CounterexampleElimination.lean). Verify whether `SetConsistent ({xi} union B)` can be supplied.
- [ ] **Task 5.3**: Implement the chosen option. If option (a): add hypothesis, update `lemma_2_7` signature, update call sites, and at each call site either prove the new precondition or handle the inconsistent case separately.
- [ ] **Task 5.4**: Run `lake build` and verify PointInsertion.lean sorry count reaches 0.

**Timing**: 2-3 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- close sorry #3
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- if option (a) or (c) requires call site changes

**Verification**:
- Sorry #3 is closed
- PointInsertion.lean sorry count: 0
- `lemma_2_7` fully sorry-free
- All call sites compile
- `lake build` passes

---

### Phase 6: c2' Co-Construction for All 5 Elimination Types [NOT STARTED]

**Goal**: Close sorries #6-10 in `eliminate_potential_counterexample` at CounterexampleElimination.lean lines 756, 794, 834, 872, 918 by co-constructing g-values (BurgessR3Maximal intermediate sets) for new adjacent pairs created by each elimination step.

**Paper reference**: Burgess Sections 2.9-2.10, p.373-374.

**Architecture**: Each elimination type (C5, C5', C4, C4', density) inserts a new point into the chronicle domain, creating new adjacent pairs. For each new pair, a g-value satisfying `BurgessR3Maximal(f(w), g(w,w_next), f(w_next))` must be co-constructed. The c2' invariant threads through `omega_chain`.

| Elimination | New point | New adjacencies | g-value source |
|-------------|-----------|-----------------|----------------|
| C5 forward | y beyond max | (x_max, y) | `lemma_2_4` output B |
| C5' backward | y before min | (y, x_min) | `lemma_2_4` mirror output |
| C4 forward | z between x,y | (x,z), (z,y) | `lemma_2_6_splitting` output B', B'' |
| C4' backward | z between x,y | (x,z), (z,y) | `lemma_2_6_splitting` mirror |
| Density | z between x,y | (x,z), (z,y) | `lemma_2_6_splitting` with arbitrary delta |

**Tasks**:
- [ ] **Task 6.1**: If needed, add a `c2'` field to `EliminationResult` in ChronicleTypes.lean or CounterexampleElimination.lean to carry the g-value proof for new adjacent pairs. Alternatively, populate existing c2' sorry sites directly.
- [ ] **Task 6.2**: Close c2' sorry for C5 forward elimination (line 756). Capture B from `lemma_2_4` output. The new adjacent pair `(x_max, y)` gets g-value B with `BurgessR3Maximal(f(x_max), B, f(y))` directly from `lemma_2_4`.
- [ ] **Task 6.3**: Close c2' sorry for C5' backward elimination (line 794). Mirror of Task 6.2 for the Since direction.
- [ ] **Task 6.4**: Close c2' sorry for C4 forward elimination (line 834). Call `lemma_2_6_splitting` on the old adjacency `(x,y)` to produce `(B', D, B'')` where `BurgessR3Maximal(f(x), B', D)` and `BurgessR3Maximal(D, B'', f(y))`. Set `g(x,z) = B'` and `g(z,y) = B''`.
- [ ] **Task 6.5**: Close c2' sorry for C4' backward elimination (line 872). Mirror of Task 6.4.
- [ ] **Task 6.6**: Close c2' sorry for density insertion (line 918). Same `lemma_2_6_splitting` approach as C4, since density insertion also splits an adjacency.
- [ ] **Task 6.7**: For each elimination type, verify that old g-values for preserved adjacent pairs are correctly inherited (unchanged pairs retain their existing c2' proofs).
- [ ] **Task 6.8**: Update `omega_chain` return type in ChronicleConstruction.lean if needed to thread c2' through the limit construction. Add `omega_chain_c2'` accessor.
- [ ] **Task 6.9**: Run `lake build` and verify CounterexampleElimination.lean sorry count drops by 5.

**Timing**: 8-12 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` lines 756, 794, 834, 872, 918 -- close c2' sorries
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` -- if `EliminationResult` needs g-value fields
- Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- thread c2' through `omega_chain`

**Verification**:
- Sorries #6-10 all closed
- CounterexampleElimination.lean sorry count: 7 -> 2 (C4 hard cases remain)
- All five elimination functions compile with populated g-values
- `omega_chain` compiles with c2' invariant
- `lake build` passes

---

### Phase 7: C4/C4' Hard Cases -- Close Sorries #4-5 [NOT STARTED]

**Goal**: Close the 2 hard-case sorries at CounterexampleElimination.lean lines 412 (C4 forward) and 510 (C4' backward) where `gamma in f(x) AND gamma in f(y)`.

**Paper reference**: Burgess Section 2.9 (C4 hard case).

**Strategy**: From c2' (now satisfied after Phase 6), we have `BurgessR3Maximal(f(w), g(w,w_next), f(w_next))`. When the C4 counterexample has `gamma in f(w)` AND `gamma in f(w_next)`:
- Case 1: `gamma not in g(w, w_next)`. Apply `BurgessR3Maximal_extension_fails` (or `BurgessR3Maximal_neg_or_ext_fails`) with candidate gamma to extract a negation witness. Construct midpoint MCS D containing `gamma.neg`.
- Case 2: `gamma in g(w, w_next)`. By C3 (`g(w,w_next) subset f(z)` for intermediate z), gamma propagates to intermediate points. Use this to construct D or show the counterexample is already eliminated.

**Tasks**:
- [ ] **Task 7.1**: Inspect the exact proof state at sorry #4 (line 412) using `lean_goal`. Understand what hypotheses are available about `gamma`, `f(w)`, `f(w_next)`, and `g(w, w_next)`.
- [ ] **Task 7.2**: Close C4 forward hard case (line 412). Apply `BurgessR3Maximal_neg_or_ext_fails` at the appropriate pair. Derive the needed midpoint MCS D with `(untl(gamma, delta)).neg in D` for the C4 counterexample elimination.
- [ ] **Task 7.3**: Close C4' backward hard case (line 510). Mirror of Task 7.2 for the Since direction.
- [ ] **Task 7.4**: Run `lake build` and verify CounterexampleElimination.lean is fully sorry-free.

**Timing**: 3-4 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` lines 412, 510 -- close C4/C4' hard cases

**Verification**:
- Sorries #4-5 both closed
- CounterexampleElimination.lean sorry count: 0
- Both C4/C4' elimination functions fully sorry-free
- `lake build` passes

---

### Phase 8: FUC/FSC Coherence and Final Audit [NOT STARTED]

**Goal**: Close sorries #11-12 at ChronicleToCountermodel.lean lines 615, 619 (forward Until coherence and forward Since coherence at the limit), then verify the entire Chronicle/ directory is sorry-free. This completes the representation theorem.

**Paper reference**: Burgess Claim 2.11, p.375 (truth lemma).

**Strategy for FUC**: Prove `limit_satisfies_c5_full` -- the strengthened C5 with guard at intermediate points:
1. From `untl(phi, psi) in limit_f(x)`, extract the finite stage n where the C5 witness y was added.
2. At stage n, the C5 elimination placed guard phi in `g_n(x, y)` for the new adjacent pair (from `lemma_2_4` output).
3. By c2' invariant: g-values persist through the omega chain (C3 ensures `g(x,y) subset f(z)` for intermediate z).
4. At the limit: `phi in limit_g(x, y)`, and by C3: `phi in limit_f(z)` for all intermediate domain points z.
5. Transfer through the Cantor isomorphism to establish FUC.

**Tasks**:
- [ ] **Task 8.1**: Prove `finite_stage_guard_in_g` in ChronicleConstruction.lean: by induction on finite stage n, when C5 elimination adds witness y for `untl(phi, psi) in f(x)`, guard phi is in every g-value for adjacent pairs between x and y at stage n. Uses c2' invariant and `lemma_2_4` output.
- [ ] **Task 8.2**: Lift to `phi in limit_g(x,y)` using C3 at the limit.
- [ ] **Task 8.3**: Prove `limit_satisfies_c5_full` combining Tasks 8.1-8.2 with `limit_satisfies_c5_weak`.
- [ ] **Task 8.4**: Prove `limit_satisfies_c5'_full` (Since mirror).
- [ ] **Task 8.5**: Close FUC sorry (ChronicleToCountermodel.lean:615). Unpack `hfam` hypothesis, apply `limit_satisfies_c5_full`, transfer through Cantor isomorphism.
- [ ] **Task 8.6**: Close FSC sorry (ChronicleToCountermodel.lean:619). Mirror of Task 8.5.
- [ ] **Task 8.7**: Final audit -- run `#print axioms dd_countermodel_chronicle` and verify no `sorryAx`.
- [ ] **Task 8.8**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- verify only comment occurrences.
- [ ] **Task 8.9**: Full `lake build` clean from scratch.

**Timing**: 6-9 hours

**Depends on**: 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- add `finite_stage_guard_in_g`, `limit_satisfies_c5_full`, `limit_satisfies_c5'_full`
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` lines 615, 619 -- close FUC/FSC sorries

**Verification**:
- Sorries #11-12 both closed
- ChronicleToCountermodel.lean sorry count: 0
- `dd_countermodel_chronicle` has no `sorryAx` in its axioms
- `grep -rn "sorry" Chronicle/` returns only comment occurrences
- Full `lake build` passes cleanly
- Total sorry count: 12 -> 0

---

## Testing & Validation

- [ ] `lake build` succeeds at every phase boundary (Phases 1-8)
- [ ] `#print axioms dd_countermodel_chronicle` -- no `sorryAx` after Phase 8
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- only comment occurrences
- [ ] `BurgessR3Maximal` maximality clause uses `SetDeductivelyClosed D` (matching Burgess 1982)
- [ ] All 12 sorries systematically closed: 3 in PointInsertion, 7 in CounterexampleElimination, 2 in ChronicleToCountermodel
- [ ] `irr_until` axiom NOT used anywhere
- [ ] No density or discreteness axioms added
- [ ] Convention alignment maintained (our `untl(guard, event)` = Burgess `U(event, guard)`) per audit
- [ ] All elimination functions' g-field populated for new adjacent pairs
- [ ] `omega_chain` type-checks with c2' invariant
- [ ] `limit_satisfies_c5_full` provable without circularity
- [ ] FUC/FSC compile using `limit_satisfies_c5_full`

## Artifacts & Outputs

- `specs/107_chain_design_diagnostics_for_representation_theorem/plans/53_implementation-plan.md` (this file)
- `specs/107_chain_design_diagnostics_for_representation_theorem/summaries/53_execution-summary.md` (after Phase 8)
- Modified source files:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (Phases 1-5)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (Phases 6-7)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (Phase 8)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` (Phase 8)
  - Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (Phase 6)
  - Possibly `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` (Phase 2)

## Rollback/Contingency

- **Phase 1 (build fix)**: Restructuring is purely syntactic. If it fails, inspect with `lean_goal` and adjust proof structure to match goal type. Worst case: manually reconstruct the by_cases block in a different position.

- **Phase 3 (pos sub-case)**: If right_mono contrapositive does not give the needed neg-untl for gamma_hat in Case A, include BOTH beta0 AND gamma0 from the delta-witness in the finite subset lists. Then both `untl(beta0 AND delta', gamma_hat) in A` and its negation are in A -- contradiction. If Case B (B is MCS) has unexpected complexity, fall back to showing B is NEVER MCS when beta not in B (since beta not in B and beta.neg in B means B lacks beta, contradicting maximality only if beta.neg not in B too -- but beta.neg IS in B by hypothesis).

- **Phase 4 (BX7 three-way)**: If D2 elimination is blocked by the non-derivability of `beta0 AND untl(beta0, gamma0) -> gamma0`, use the alternative path: right_mono D2 event to eta (which IS in the event), getting `untl(beta0 AND xi, eta)`. Then apply BX14 with the witness `(untl(beta0 AND xi, gamma0)).neg` to separate. If both D1 and D2 elimination fail, try a combined argument or consult the exact BX7 disjunct forms via `lean_goal`.

- **Phase 5 (inconsistent case)**: If option (b) fails and option (a) requires call site changes, option (c) provides a self-contained fallback: handle `xi.neg in B` at the C5 elimination level without invoking `lemma_2_7` at all.

- **Phase 6 (c2' co-construction)**: If modifying EliminationResult types is too invasive, prove c2' as a separate theorem by induction on the omega_chain rather than threading through the structure. Implement simpler cases first (C5/C5') before tackling C4/C4'/density.

- **Phase 8 (FUC/FSC)**: If `finite_stage_guard_in_g` proves unprovable via induction on finite stages, fall back to a direct argument using limit_g definition (intersection of intermediate f-values) plus c2' invariant. If Cantor isomorphism mapping is problematic, work directly with the limit structure.

- **General**: Commit after each phase boundary. Any phase can be reverted by checking out the prior commit. The git history provides full traceability.
