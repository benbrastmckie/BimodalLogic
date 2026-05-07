# Implementation Plan: Task #107 -- Sorry-Free bx_completeness via Guard Threading and Convention Alignment (Revised)

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [NOT STARTED]
- **Effort**: 35-50 hours (23-34h sorry closure + 2-4h NoUnivBurgessR3 + 8-16h convention migration + 3-4h cleanup)
- **Dependencies**: None (all prerequisite infrastructure exists; Phases 1-2 of prior plan v63 completed)
- **Research Inputs**: reports/64_team-research.md, handoffs/64_phase1-4-handoff.md
- **Artifacts**: plans/64_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 2 remaining sorry sites in ChronicleConstruction.lean (lines 1445, 1457) and prove NoUnivBurgessR3 to deliver a fully unconditional, sorry-free `bx_completeness` theorem. The sorries require proving `ξ ∈ limit_f(w)` for intermediate w between x and y at the limit. The closure chain is: (a) prove a guard conjunction theorem from BX7, (b) strengthen `lemma_2_7`/`2_8` in PointInsertion.lean to return `xi ∈ B'` via DC(B∪{xi}) Zorn seed, (c) strengthen `EliminationResult.c5_forward_witness` to return an **adjacent-pair guard condition** (`∀ a b, Adjacent val.dom a b → pc.x ≤ a → b ≤ y → pc.ξ ∈ val.g a b`), (d) restructure Walk A (pc.x < max_old) to split at (pc.x, x') instead of walking, remove Walk B eta-shortcut entirely, (e) mirror for Since, (f) strengthen `omega_chain_c5_witness` and close the 2 sorries using `adj_g_mem_limit_f`. After sorry closure, prove `NoUnivBurgessR3` and migrate untl/snce convention. Definition of done: `#print axioms bx_completeness` shows no `sorryAx`; `lake build` succeeds; convention matches Burgess 1982.

### Revision Notes (v2)

**Why revised**: The v1 plan specified `pc.ξ ∈ val.g pc.x y` as the strengthened return type. Implementation analysis (handoff `64_phase1-4-handoff.md`) showed this is mathematically impossible for non-adjacent pairs — the chronicle's g-function at finite stages is empty for non-adjacent domain pairs (inherited from `singleton_chronicle`). Walk A (pc.x < max_old) produces a non-adjacent witness, and Walk B eta-shortcut is provably contradictory with the guard. The corrected approach uses adjacent-pair guard conditions and requires prerequisite work (guard conjunction theorem, lemma_2_7 strengthening) plus structural changes to Walk A/B.

### Research Integration

**Report 64 (team-research.md)**: Four-teammate analysis confirming three blockers: (1) 2 sorry sites needing guard threading, (2) NoUnivBurgessR3 as unproved hypothesis, (3) convention migration. Key infrastructure exists: `adj_g_mem_limit_f`, `lemma_2_4_with_guard`, `burgessR3Maximal_with_guard`.

**Handoff 64 (phase1-4-handoff.md)**: Detailed case-by-case analysis proving the v1 return type wrong and identifying the correct adjacent-pair guard approach. Contains prerequisite analysis for guard conjunction theorem and lemma_2_7 strengthening via DC(B∪{xi}).

### Prior Plan Reference

Plan v63 Phases 1-2 completed: `lemma_2_4_with_guard` created, `lemma_2_7` fixed to return `B ⊆ B'`, Burgess 2.10 condition (i) aligned. Phase 3 Tasks 3.1-3.6 completed (g_sub_f_insert, g_sub_g_new, dom_new_unique, adj_g_mem_limit_f all proved). Tasks 3.7-3.8 blocked by the return type issue identified in this revision.

## Goals & Non-Goals

**Goals**:
- Prove guard conjunction theorem from BX7 + BX3
- Strengthen `lemma_2_7`/`2_8` to return `xi ∈ B'` via DC(B∪{xi}) Zorn seed
- Strengthen `EliminationResult.c5_forward_witness` with adjacent-pair guard condition
- Restructure Walk A (split at (pc.x, x') instead of walking to max_old)
- Remove Walk B eta-shortcut (always split at (u_max, u_next))
- Mirror all changes for Since direction
- Close the 2 sorry sites at ChronicleConstruction.lean:1445,1457
- Prove `NoUnivBurgessR3` and make `bx_completeness` unconditional
- Migrate untl/snce convention to match Burgess U(event, guard)
- Update stale ROADMAP sorry documentation

**Non-Goals**:
- Restructure the omega chain or limit construction architecture
- Close the 15 BXCanonical dead-code sorries (task 109 scope)
- Close the 19 TemporalDerived.lean invalid stubs (separate task)
- Generalize beyond D=Rat (Burgess uses Q as concrete construction medium)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Guard conjunction from BX7 requires careful case analysis of 3 disjuncts | Delays Phase 1 | Medium | BX7 with psi=theta=delta collapses all 3 disjuncts via right-monotonicity (BX3). The proof pattern is well-known. |
| DC(B∪{xi}) Zorn seed: proving `burgessR3(A, DC(B∪{xi}), D)` is non-trivial | Delays Phase 2 | Medium | Guard conjunction theorem (Phase 1) provides the key step. Existing `dc_delta_B_burgessR3` handles the structural argument. The Since-half `h_snce_conj_xi_D` already exists at PointInsertion.lean:3669. |
| Walk A restructuring (split instead of walk) may require significant code removal | Extends Phase 4 | High | The restructuring replaces ~150 lines of walk logic with ~80 lines of direct splitting. Net reduction in code. Condition (i) directly provides the splitting prerequisites. |
| Walk B eta-shortcut removal breaks existing case structure | Extends Phase 4 | Medium | The shortcut is only ~20 lines. Removing it and falling through to splitting at (u_max, u_next) is straightforward given the strengthened lemma_2_7. |
| EliminationResult type change cascades through 18+ sites | Extended effort | High | Non-C5 cases extend trivially via absurd. Only ~6 active C5 forward cases + mirrors need real guard proofs. Commit after each batch. |
| Convention migration causes silent semantic corruption | Breaks correctness | Medium | Strategy B (full swap + rename) + `lake build` + manual audit of 10 axioms + 5 lemmas. Separate commit for clean revert. |

## Implementation Phases

**Dependency Analysis**:

| Wave | Phases | Blocked by |
|------|--------|------------|
| 1 | 1 | -- |
| 2 | 2 | 1 |
| 3 | 3 | 2 |
| 4 | 4, 5 | 3 |
| 5 | 6 | 4, 5 |
| 6 | 7 | 6 |
| 7 | 8 | 7 |
| 8 | 9 | 7, 8 |
| 9 | 10 | 8, 9 |
| 10 | 11 | 9, 10 |

Phases within the same wave can execute in parallel.

---

### Phase 1: Guard Conjunction Theorem [COMPLETED]

**Goal**: Prove that `U(α,γ) ∧ U(β,γ) → U(α∧β,γ)` (in our convention: `untl(α,γ) ∈ A ∧ untl(β,γ) ∈ A → untl(α∧β,γ) ∈ A` for MCS A). This is the prerequisite for strengthening lemma_2_7's Zorn seed.

**Paper reference**: Derived from BX7 (linear_until / A7a) + BX3 (right_mono_until / A2a). BX7 with the same second argument: `U(α,δ) ∧ U(β,δ) → U(α∧β, δ∧δ) ∨ U(α∧β, δ∧β) ∨ U(α∧β, α∧δ)`. Since `⊢ δ∧δ → δ`, `⊢ δ∧β → δ`, and `⊢ α∧δ → δ`, BX3 (right monotonicity) gives `U(α∧β, δ)` in all three disjuncts.

**Tasks**:
- [x] **Task 1.1**: Prove derivation-level guard conjunction: `⊢ untl(α,γ) ∧ untl(β,γ) → untl(α∧β,γ)`. Uses `linear_until` (BX7) + `right_mono_until` (BX3). ~20-30 lines in PointInsertion.lean or Theorems/TemporalDerived.lean. **EXISTED**: `untl_conj_guard` in RRelation.lean:972 (MCS-level, combines 1.1+1.2).
- [x] **Task 1.2**: Prove MCS-level guard conjunction: for MCS A, `untl(α,γ) ∈ A → untl(β,γ) ∈ A → untl(α∧β,γ) ∈ A`. Follows from Task 1.1 via `mcs_mem_of_derivable`. ~10 lines. **EXISTED**: `untl_conj_guard` in RRelation.lean:972.
- [x] **Task 1.3**: Prove set-level guard conjunction: `burgessR(A, α, D) → burgessR(A, β, D) → burgessR(A, α∧β, D)`. For all δ ∈ D: `untl(α,δ) ∈ A` and `untl(β,δ) ∈ A` → `untl(α∧β,δ) ∈ A`. ~15 lines. **NEW**: `burgessR_conj` + `burgessRSince_conj` in RRelation.lean:1062,1080.
- [x] **Task 1.4**: Mirror for Since: `snce(α,γ) ∧ snce(β,γ) → snce(α∧β,γ)`. Uses `linear_since` (BX7 mirror) + `right_mono_since`. ~20 lines. **EXISTED**: `snce_conj_guard` in RRelation.lean:1018.
- [x] **Task 1.5**: Run `lake build` to verify. **PASSED**: Build completed successfully (1097 jobs).

**Timing**: 2-3 hours

**Depends on**: none

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (or `Theories/Bimodal/Theorems/TemporalDerived.lean`) -- guard conjunction theorems

**Verification**:
- All guard conjunction lemmas compile without sorry
- `lake build` passes

---

### Phase 2: Strengthen lemma_2_7/2_8 to Return xi ∈ B' [COMPLETED]

**Goal**: Modify `lemma_2_7` (PointInsertion.lean:3616) to start the Zorn construction for B' from `DC(B ∪ {xi})` instead of `B`, producing `xi ∈ B'` in addition to the existing `B ⊆ B'`. Mirror for `lemma_2_8`, `lemma_2_7_since`, `lemma_2_8_since`.

**Paper reference**: Burgess 2.7 (p.372). The conclusion states "η ∈ B'" (guard in B') which is our `xi ∈ B'`. The seed D₀ includes `{S(β∧η, α) : β ∈ B, α ∈ A}` ensuring `burgessR(A, β∧η, D)` for all β ∈ B. Combined with the guard conjunction theorem (Phase 1), this gives `burgessR(A, φ, D)` for all φ ∈ DC(B ∪ {η})`.

**Strategy**:
1. Use guard conjunction (Phase 1) to derive: for all β ∈ B, `burgessR(A, β∧xi, D)` from `burgessR(A, β, D)` and `burgessR(A, xi, D)`.
2. Apply `dc_delta_B_burgessR3` with the enriched Until obligations to get `burgessR3(A, DC(B∪{xi}), D)`.
3. Replace `burgessR3Maximal_extension_exists h_B_dcs h_r3_ABD h_no_univ_AD` with a call starting from `DC(B∪{xi})`.
4. Since `B ∪ {xi} ⊆ DC(B∪{xi}) ⊆ B'`, both `B ⊆ B'` and `xi ∈ B'` follow.

**Tasks**:
- [x] **Task 2.1**: In `lemma_2_7`, prove `burgessR(A, β∧xi, D)` for all β ∈ B. Uses guard conjunction (Phase 1 Task 1.3) with `burgessR(A, β, D)` (from `h_rSet_A`) and `burgessR(A, xi, D)` (from `h_burgessR_xi` at line 3687). ~15 lines. **DONE**: Steps 6-6b in lemma_2_7.
- [x] **Task 2.2**: Prove `burgessRSince(D, β∧xi, A)` for all β ∈ B. Already exists as `h_snce_conj_xi_D` at line 3669. Verify and connect. ~5 lines. **DONE**: Already in seed (5th component).
- [x] **Task 2.3**: Apply `dc_delta_B_burgessR3` to derive `burgessR3(A, DC(B∪{xi}), D)`. ~20 lines. **DONE**: Step 6c in lemma_2_7.
- [x] **Task 2.4**: Prove `SetDeductivelyClosed (deductiveClosure (B ∪ {xi}))` -- true by definition of deductiveClosure. ~5 lines. **DONE**: Step 6d, via contrapositive (DC≠univ → consistent → DCS).
- [x] **Task 2.5**: Change the Zorn invocation from seed `B` to seed `DC(B∪{xi})`. Extract `xi ∈ B'` from `DC(B∪{xi}) ⊆ B'`. Add `xi ∈ B'` to the return type. ~20 lines. **DONE**: Step 6e, return type extended with `∧ xi ∈ B'`.
- [x] **Task 2.6**: Update callers of `lemma_2_7` in CounterexampleElimination.lean to accept the enriched return (destructure the additional `xi ∈ B'` component). ~10 lines per call site. **DONE**: 8 call sites updated with `_` for the extra component.
- [x] **Task 2.7**: Mirror for `lemma_2_8` (same structure, different seed consistency proof). ~60 lines. **DONE**: Same DC seed approach; added Steps 5b-5d + Step 6 to lemma_2_8.
- [x] **Task 2.8**: Mirror for `lemma_2_7_since` and `lemma_2_8_since` (backward direction). **DONE**: Added 5th seed component `{untl(β∧xi,γ) | β∈B, γ∈C}` to Since seed. Updated seed_consistent proofs with l27s_ extraction helpers for component 5. Strengthened both lemmas to return `xi ∈ B''` via DC(B∪{xi}) Zorn seed. Updated 6 caller sites in CounterexampleElimination.lean.
- [x] **Task 2.9**: Run `lake build` to verify all changes compile. **PASSED**: Build completed successfully (1097 jobs), 0 new sorries, 0 new axioms.

**Timing**: 4-6 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` -- lemma_2_7, lemma_2_8, lemma_2_7_since, lemma_2_8_since
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- update call sites

**Verification**:
- All four splitting lemmas return `xi ∈ B'` without sorry
- All callers updated and compile
- `lake build` passes

---

### Phase 3: Strengthen EliminationResult with Adjacent-Pair Guard [COMPLETED]

**Goal**: Modify `c5_forward_witness` and `c5_backward_witness` return types to use the adjacent-pair guard condition instead of simple g-membership.

**Paper reference**: Burgess 2.10 (p.374). C5a requires `η ∈ g(x,y)`, which in the finite-stage chronicle means: for every adjacent pair (a,b) between x and y, `η ∈ g(a,b)`. The adjacent-pair formulation is the correct way to express this for non-adjacent witnesses.

**Tasks**:
- [x] **Task 3.1**: Change `c5_forward_witness` (CE:612-614) from `∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y` to `∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y ∧ ∀ a b, Adjacent val.dom a b → pc.x ≤ a → b ≤ y → pc.ξ ∈ val.g a b`. **DONE**: Type changed at CE:612-616.
- [x] **Task 3.2**: Change `c5_backward_witness` (CE:615-617) similarly with reversed ordering. **DONE**: Type changed at CE:617-621 with `y ≤ a → b ≤ pc.x` guard ordering.
- [x] **Task 3.3**: Fix all non-C5 case sites where `c5_forward_witness`/`c5_backward_witness` are proved via `absurd`/`decide`. The strengthened type makes these require one more universally-quantified clause, but `absurd` still suffices since the hypothesis `pc.kind = .c5_forward` is False for non-C5 cases. ~mechanical updates. **DONE**: No changes needed -- all 16 absurd sites compile unchanged because `absurd` derives `False` from kind mismatch and produces any target type.
- [x] **Task 3.4**: Run `lake build` to identify remaining compilation errors from C5 case sites. **DONE**: 12 errors identified (6 forward C5 active cases at lines 758, 929, 1002, 1181, 1414, 1485; 6 backward C5 active cases at lines 1595, 1744, 1812, 1947, 2171, 2242). These are expected and will be fixed in Phases 4-5.

**Timing**: 1-2 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- EliminationResult type + non-C5 case sites

**Verification**:
- EliminationResult compiles with strengthened types
- Non-C5 case construction sites compile
- `lake build` identifies only C5-case compilation errors (expected, fixed in Phases 4-5)

---

### Phase 4: Fix C5 Forward Cases with Walk Restructuring [NOT STARTED]

**Goal**: Fix all C5 forward case constructions to provide the adjacent-pair guard. This includes restructuring Walk A (split instead of walk when pc.x < max_old), removing Walk B eta-shortcut, and threading guard through splitting cases.

**Paper reference**: Burgess 2.10 (p.374) condition (i): guard ∈ g(x, x') at each walk step. Burgess 2.7 (splitting with xi ∈ B'). The key mathematical insight: when condition (i) holds at (pc.x, x'), this gives exactly the prerequisites for splitting at (pc.x, x') instead of continuing to walk.

**Case-by-case approach** (from handoff analysis):

| Case | Witness y | Adjacent pairs (pc.x, y) | Guard source |
|------|-----------|--------------------------|-------------|
| **n=0** | y beyond max_old, (pc.x, y) adjacent | Only (pc.x, y) | `xi ∈ B` from `lemma_2_4_with_guard` |
| **Walk A, pc.x = max_old** | Same as n=0 | Only (max_old, y) | `xi ∈ B_l24` from `lemma_2_4_with_guard` |
| **Walk A, pc.x < max_old** | RESTRUCTURE: split at (pc.x, x') | (pc.x, z) only | Cond(i) gives `xi ∈ g(pc.x, x')` → `xi ∈ B'` via g⊆B' |
| **Walk B splitting** | z = midpoint(u_max, u_next) | (u_max, z), (z, u_next) | Strengthened `lemma_2_7` gives `xi ∈ B'` |
| **Not-cond(i) splitting** | z = midpoint(pc.x, x') | (pc.x, z), (z, x') | If xi∈g: g⊆B'. If xi∉g: strengthened `lemma_2_7` gives xi∈B' |
| **Not-actual** | y from push_neg | (pc.x, y) must be adjacent | Guard from `push_neg at h_actual` |

**Tasks**:
- [ ] **Task 4.1**: Fix **not-actual case** (CE:1476-1480): Stop discarding guard witness. Change `⟨y, hy_dom, hy_lt, hy_η, _⟩` to `⟨y, hy_dom, hy_lt, hy_η, h_guard⟩`. Prove the adjacent-pair condition: since val=χ (unchanged), y is an existing domain point, and (pc.x, y) should be adjacent (the only pair). Thread `h_guard` through. ~10-15 lines.
- [ ] **Task 4.2**: Fix **n=0 case** (CE near 848): Switch `lemma_2_4` → `lemma_2_4_with_guard` to get `xi ∈ B`. Since the new point y is adjacent to pc.x, the only adjacent pair is (pc.x, y) with g(pc.x, y) = B. Guard follows from `xi ∈ B`. ~15-20 lines.
- [ ] **Task 4.3**: Fix **Walk A, pc.x = max_old**: Equivalent to n=0 case. Apply same fix. ~5 lines.
- [ ] **Task 4.4**: **RESTRUCTURE Walk A, pc.x < max_old**: Replace the walk-to-max_old logic with direct splitting at (pc.x, x'). When condition (i) holds: `xi ∈ g(pc.x, x')` and `xi∧U(xi,η) ∈ f(x')` and `η ∉ f(x')`. This is the splitting setup — apply lemma_2_7/2_8/2_6 at (pc.x, x'). The splitting produces z = midpoint(pc.x, x') with g'(pc.x, z) = B' ⊇ g(pc.x, x') ∋ xi. The witness z is adjacent to pc.x. ~80-120 lines (replacing ~150 lines of walk logic).
- [ ] **Task 4.5**: **REMOVE Walk B eta-shortcut** (CE:994-997): Delete the branch that returns χ unchanged when `η ∈ f(u_next)`. Always fall through to splitting at (u_max, u_next). ~-20 lines (deletion).
- [ ] **Task 4.6**: Fix **Walk B splitting** (after removing shortcut): Split at (u_max, u_next). Case on `xi ∈ g(u_max, u_next)`:
  - If yes: g ⊆ B' from splitting gives `xi ∈ B'`. Guard at both adjacent pairs.
  - If no: strengthened `lemma_2_7` (Phase 2) gives `xi ∈ B'` directly.
  ~40-60 lines.
- [ ] **Task 4.7**: Fix **not-condition(i) splitting cases**: For each sub-case using lemma_2_6/2_7/2_8:
  - If `xi ∈ g(pc.x, x')`: g ⊆ B' gives guard. No change needed.
  - If `xi ∉ g(pc.x, x')`: redirect to use strengthened lemma_2_7 which returns `xi ∈ B'` regardless.
  ~30-50 lines.
- [ ] **Task 4.8**: Run `lake build` to verify all C5 forward cases compile with adjacent-pair guard.

**Timing**: 6-8 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- all C5 forward case construction sites

**Verification**:
- All C5 forward case constructions compile with adjacent-pair guard
- No sorry introduced
- Walk A restructured (walk-to-max_old logic replaced)
- Walk B eta-shortcut removed
- `lake build` passes (C5 backward errors may remain)

---

### Phase 5: Fix C5 Backward (Since) Cases [NOT STARTED]

**Goal**: Mirror Phase 4 for all C5 backward (Since) case constructions. Apply the same restructuring (walk → split, remove eta-shortcut, thread guard through splitting).

**Paper reference**: Burgess C5b (Since mirror of C5a). All arguments are symmetric.

**Tasks**:
- [ ] **Task 5.1**: Fix **not-actual since case**: Stop discarding guard, mirror of Phase 4 Task 4.1. ~10-15 lines.
- [ ] **Task 5.2**: Fix **backward n=0 case**: Switch to `lemma_2_4_with_guard` (Since variant). ~15-20 lines.
- [ ] **Task 5.3**: **RESTRUCTURE backward Walk A** (pc.x > min_old): Replace walk-to-min_old with splitting at (x'', pc.x). Mirror of Phase 4 Task 4.4. ~80-120 lines.
- [ ] **Task 5.4**: **REMOVE backward Walk B eta-shortcut**. ~-20 lines.
- [ ] **Task 5.5**: Fix **backward Walk B splitting**. Uses `lemma_2_7_since`/`lemma_2_8_since`. ~40-60 lines.
- [ ] **Task 5.6**: Fix **backward not-condition(i) splitting cases**. ~30-50 lines.
- [ ] **Task 5.7**: Run `lake build` to verify all CounterexampleElimination.lean compiles clean.

**Timing**: 4-6 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- C5 backward case sites

**Verification**:
- All C5 backward case constructions compile with adjacent-pair guard
- CounterexampleElimination.lean has 0 sorry sites
- `lake build` passes

---

### Phase 6: Strengthen omega_chain_c5_witness and Close 2 Sorries [NOT STARTED]

**Goal**: Strengthen `omega_chain_c5_witness` (ChronicleConstruction.lean:392) to return the adjacent-pair guard from the elimination stage, then close the 2 sorry sites at lines 1445 and 1457 using `adj_g_mem_limit_f`.

**Paper reference**: Burgess 2.11 (truth lemma, p.375). The full C5a with guard: `U(ξ,η) ∈ limit_f(x) → ∃ y, η ∈ limit_f(y) ∧ ξ ∈ limit_g(x,y)`.

**Tasks**:
- [ ] **Task 6.1**: Strengthen `omega_chain_c5_witness` return type (CC:392-399) to include `∧ ∀ a b, Adjacent (omega_chain_val ...).dom a b → pc.x ≤ a → b ≤ y → pc.ξ ∈ (omega_chain_val ...).g a b`. This follows directly from the strengthened `EliminationResult.c5_forward_witness`. ~15-20 lines.
- [ ] **Task 6.2**: Strengthen `omega_chain_c5'_witness` (CC:418-438) similarly for Since. ~15-20 lines.
- [ ] **Task 6.3**: Prove `limit_satisfies_c5_strong` guard step (CC:1445). The proof:
  1. From strengthened `omega_chain_c5_witness`, obtain `∀ a b, Adjacent dom_{n+1} a b → pc.x ≤ a → b ≤ y → ξ ∈ g_{n+1}(a,b)` where y is the C5 witness at stage n+1.
  2. For any w ∈ limit_dom with x < w < y: w was inserted at some stage m ≥ n+1. At stage m, w sits between some adjacent pair (a,b) at stage n+1 with x ≤ a and b ≤ y.
  3. Apply `adj_g_mem_limit_f` (CC:1406): `ξ ∈ g_{n+1}(a,b)` → `ξ ∈ limit_f(w)`.
  ~30-40 lines.
- [ ] **Task 6.4**: Close `limit_satisfies_c5'_strong` guard sorry (CC:1457). Mirror of Task 6.3 for Since. ~30-40 lines.
- [ ] **Task 6.5**: Run `lake build` and `grep -rn "sorry" Chronicle/` to verify 0 sorry sites on critical path.

**Timing**: 2-3 hours

**Depends on**: 4, 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- omega_chain_c5_witness, limit_satisfies_c5_strong, Since mirrors

**Verification**:
- Both sorry sites at CC:1445 and CC:1457 are closed
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comment/doc occurrences
- `lake build` passes

---

### Phase 7: Prove NoUnivBurgessR3 [NOT STARTED]

**Goal**: Prove `NoUnivBurgessR3` as a theorem and make `bx_completeness` unconditional.

**Paper reference**: `burgessR3 A Set.univ C` requires `Set.univ` to satisfy the r-relation conditions. But `Set.univ` is inconsistent (contains both φ and ¬φ). The burgessR3Maximal Zorn construction requires the interval set B to not be Set.univ. Direct proof: `burgessR3 A Set.univ C` → `Set.univ` is `ClosedUnderDerivation` (true) → `Set.univ` contains ⊥ (from ⊢ φ ∧ ¬φ → ⊥) → contradicts A being MCS (which requires `⊥ ∉ A`) via the r-relation `∀ γ ∈ C, untl(⊥, γ) ∈ A` and BX derivability of `untl(⊥, γ) → ⊥`.

**Tasks**:
- [ ] **Task 7.1**: Prove `noUnivBurgessR3 : NoUnivBurgessR3` in ChronicleTypes.lean or a new file. ~50-100 lines.
- [ ] **Task 7.2**: Modify `bx_completeness` (Completeness.lean:128) to use `noUnivBurgessR3` directly. ~5-10 lines.
- [ ] **Task 7.3**: Update all callers of `bx_completeness`. ~5 lines.
- [ ] **Task 7.4**: Run `#print axioms bx_completeness` and verify no `sorryAx`. Run `lake build`.

**Timing**: 2-4 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (or new file) -- NoUnivBurgessR3 proof
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- unconditional bx_completeness

**Verification**:
- `NoUnivBurgessR3` proved without sorry
- `bx_completeness` takes no hypothesis parameters beyond `φ : Formula`
- `#print axioms bx_completeness` shows no `sorryAx`
- `lake build` passes

---

### Phase 8: Final Sorry-Free Validation [NOT STARTED]

**Goal**: Comprehensive validation that `bx_completeness` is truly sorry-free.

**Tasks**:
- [ ] **Task 8.1**: Run `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` -- only comments.
- [ ] **Task 8.2**: Run `grep -n "sorry" Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- only comments.
- [ ] **Task 8.3**: Run `#print axioms bx_completeness` and capture output.
- [ ] **Task 8.4**: Full `lake build` from clean state.
- [ ] **Task 8.5**: Update Completeness.lean header comments to reflect sorry-free status.

**Timing**: 1 hour

**Depends on**: 7

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` -- update comments

**Verification**:
- Zero sorry sites on critical path
- `bx_completeness` axiom-clean (no sorryAx)
- Clean `lake build`

---

### Phase 9: Convention Migration -- untl/snce Argument Swap [NOT STARTED]

**Goal**: Migrate `untl(guard, event)` to `untl(event, guard)` and `snce(guard, event)` to `snce(event, guard)` across the entire codebase to match Burgess 1982's convention.

**Paper reference**: Burgess 1982, Section 1.2 (p.367): `V(U(alpha, beta))` where alpha = event, beta = guard.

**Research input**: Report 67 (convention-migration-research.md) -- 33 files, ~2141 references. Strategy B recommended.

**Tasks**:
- [ ] **Task 9.1**: Swap `untl`/`snce` constructor argument order in `Formula.lean`. Update `next`/`prev`.
- [ ] **Task 9.2**: Swap in `Truth.lean` semantics (2 lines).
- [ ] **Task 9.3**: Swap in `Axioms.lean` (~35 axiom definitions + mirrors).
- [ ] **Task 9.4**: Update `burgessR`/`burgessRSince` and all Chronicle types in `ChronicleTypes.lean`.
- [ ] **Task 9.5**: Update all `Formula.untl`/`Formula.snce` constructions across ~33 files. Error-driven iteration.
- [ ] **Task 9.6**: Rename variables for clarity where feasible.
- [ ] **Task 9.7**: Update convention comments and documentation.
- [ ] **Task 9.8**: Full `lake build`. Verify `#print axioms bx_completeness` unchanged.
- [ ] **Task 9.9**: Audit: spot-check 10 axiom proofs + 5 Chronicle lemmas for semantic correctness.

**Timing**: 8-16 hours

**Depends on**: 8

**Files to modify**: ~33 files across Syntax/, Semantics/, ProofSystem/, Metalogic/, Theorems/, Automation/, Examples/

**Verification**:
- `lake build` passes
- `#print axioms bx_completeness` unchanged
- Convention matches Burgess throughout
- Spot-check audit passes

---

### Phase 10: ROADMAP and Documentation Cleanup [NOT STARTED]

**Goal**: Update stale ROADMAP sorry tables, Completeness.lean comments, and mark invalid stubs.

**Tasks**:
- [ ] **Task 10.1**: Update ROADMAP.md sorry tables (9→0 critical-path, update counts).
- [ ] **Task 10.2**: Update Completeness.lean comments (remove stale sorry references).
- [ ] **Task 10.3**: Update plan v63 phase statuses.
- [ ] **Task 10.4**: Document (but do NOT delete) the 19 TemporalDerived.lean invalid sorry stubs.

**Timing**: 1-2 hours

**Depends on**: 8, 9

**Files to modify**:
- `specs/ROADMAP.md`
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean`
- `specs/107_.../plans/63_implementation-plan.md`

**Verification**:
- ROADMAP sorry counts accurate
- No stale documentation

---

### Phase 11: Final Integration and Summary [NOT STARTED]

**Goal**: Create execution summary and perform final validation.

**Tasks**:
- [ ] **Task 11.1**: Run comprehensive validation: `lake build`, `#print axioms`, grep sorry.
- [ ] **Task 11.2**: Verify `irr_until` axiom NOT used.
- [ ] **Task 11.3**: Verify no density/discreteness axioms added.
- [ ] **Task 11.4**: Create execution summary artifact.

**Timing**: 1 hour

**Depends on**: 9, 10

**Files to modify**:
- `specs/107_chain_design_diagnostics_for_representation_theorem/summaries/64_execution-summary.md`

**Verification**:
- All validation checks pass
- Summary accurate

---

## Testing & Validation

- [ ] `lake build` succeeds at every phase boundary
- [ ] `#print axioms bx_completeness` -- no `sorryAx` after Phase 7
- [ ] `grep -rn "sorry" Chronicle/` -- only comment/doc after Phase 6
- [ ] After Phase 9: convention matches Burgess U(event, guard)
- [ ] No density or discreteness axioms added
- [ ] `irr_until` axiom NOT used
- [ ] All new lemmas follow Burgess 1982 exactly -- no novel approaches
- [ ] Spot-check audit: 10 axioms + 5 Chronicle lemmas correct after convention swap

## Artifacts & Outputs

- `specs/107_chain_design_diagnostics_for_representation_theorem/plans/64_implementation-plan.md` (this file)
- `specs/107_chain_design_diagnostics_for_representation_theorem/summaries/64_execution-summary.md` (after Phase 11)
- Modified source files:
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` (Phases 1-2: guard conjunction, lemma_2_7/2_8 strengthening)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` (Phases 3-5: EliminationResult type + walk restructuring + all cases)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` (Phase 6: omega_chain_c5_witness + close 2 sorries)
  - `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` (Phase 7: NoUnivBurgessR3)
  - `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` (Phase 7: unconditional bx_completeness)
  - ~33 files (Phase 9: convention migration)
  - `specs/ROADMAP.md` (Phase 10: documentation update)

## Rollback/Contingency

- **Phase 1 (guard conjunction)**: Low risk -- standard derivation from BX7+BX3. If BX7 form doesn't yield clean disjunct collapse, use `omega_or_elim3` to handle all three cases.

- **Phase 2 (lemma_2_7 strengthening)**: Medium risk. If `dc_delta_B_burgessR3` doesn't accept the enriched seed, alternative: start from `DC({xi})` using `burgessR3Maximal_with_guard` (gives xi ∈ B' but NOT B ⊆ B'), then extend B' via a second Zorn step from B.

- **Phase 4 (Walk A restructuring)**: High risk. If removing walk-to-max_old introduces unforeseen issues, fallback: keep the walk but add a guard-tracking invariant (`∀ walk steps, xi ∈ g(walk[i], walk[i+1])`). This is more complex but preserves the existing structure.

- **Phase 7 (NoUnivBurgessR3)**: Independent of Phases 1-6. Can be deferred as a separate task if the proof is harder than expected.

- **Phase 9 (convention migration)**: Separate commit for clean revert. Silent corruption is the main risk. The audit in Task 9.9 is critical.

- **General**: Commit after each phase. `git revert` at any phase boundary.
