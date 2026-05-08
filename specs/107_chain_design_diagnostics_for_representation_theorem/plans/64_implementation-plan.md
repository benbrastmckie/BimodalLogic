# Implementation Plan: Task #107 -- Sorry-Free bx_completeness via Guard Threading and Convention Alignment (Revised)

- **Task**: 107 - chain_design_diagnostics_for_representation_theorem
- **Status**: [IN PROGRESS]
- **Effort**: 35-50 hours (Phases 1–6 completed; ~32h spent; Phase 7 in progress; 5 phases remaining)
- **Dependencies**: None (all prerequisite infrastructure exists; Phases 1-2 of prior plan v63 completed)
- **Research Inputs**: reports/64_team-research.md, handoffs/64_phase1-4-handoff.md
- **Artifacts**: plans/64_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-formats.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

Close the 2 remaining sorry sites in ChronicleConstruction.lean and make `bx_completeness` unconditional, then migrate conventions to match Burgess 1982. Phases 1-5 established guard conjunction, lemma strengthening, adjacent-pair guard threading, and walk restructuring. Phase 6 closed both sorries by adding `witness_not_old` tracking to prove the `y ∈ dom_n ∧ w ∈ dom_{n+1} \ dom_n` case is impossible. Phase 7 (revised): `NoUnivBurgessR3` was found to be **unprovable** in J₀ — `burgessR3(A, Set.univ, C)` is satisfiable in discrete orders. The fix is to revert `BurgessR3Maximal` to SDC-maximality (matching Burgess 1982's actual construction), removing the false `NoUnivBurgessR3` hypothesis from all ~733 references. This makes `bx_completeness` unconditional by deleting the hypothesis rather than proving it. Definition of done: `#print axioms bx_completeness` shows no `sorryAx`; `lake build` succeeds; convention matches Burgess 1982.

### Progress Summary

| Phase | Status | Key Deliverables |
|-------|--------|-----------------|
| 1 | ✅ COMPLETED | `burgessR_conj`, `burgessRSince_conj` in RRelation.lean |
| 2 | ✅ COMPLETED | `lemma_2_7`/`lemma_2_8` (and Since mirrors) strengthened to return `xi ∈ B'` |
| 3 | ✅ COMPLETED | `EliminationResult.c5_forward_witness`/`c5_backward_witness` use adjacent-pair guard |
| 4 | ✅ COMPLETED | Walk A restructured (split instead of walk), Walk B eta-shortcut removed |
| 5 | ✅ COMPLETED | All C5 backward cases compile; `CounterexampleElimination.lean` has 0 sorries |
| 6 | ✅ COMPLETED | `witness_not_old` added to walk results, disjunct `(y ∉ χ.dom ∨ ∀ u ∈ val.dom, u ∈ χ.dom)` threaded through EliminationResult/omega_chain; both sorries closed via contradiction |
| 7 | ⏳ IN PROGRESS | Revert `BurgessR3Maximal` to SDC-maximality; remove `NoUnivBurgessR3` (~733 refs, 7 files) |
| 8 | ⏳ NOT STARTED | Final sorry-free validation |
| 9 | ⏳ NOT STARTED | Convention migration (untl/snce argument swap) |
| 10 | ⏳ NOT STARTED | ROADMAP/documentation cleanup |
| 11 | ⏳ NOT STARTED | Final integration and summary |

### Revision Notes (v3 — Phase 7 redesign)

**Why revised**: Research found `NoUnivBurgessR3` is **unprovable** in J₀. Under open-guard semantics, `untl(⊥, γ)` is satisfiable in discrete orders (empty open interval between adjacent points), so `burgessR3(A, Set.univ, C)` is consistent. The CUD-maximality design (using `ClosedUnderDerivation` in `BurgessR3Maximal`'s maximality clause) was stronger than Burgess 1982's actual construction, requiring the false `NoUnivBurgessR3` as compensation. The fix is to revert to SDC-maximality (`SetDeductivelyClosed` in the maximality clause), matching Burgess exactly. This eliminates the hypothesis entirely — `bx_completeness` becomes unconditional by removing the parameter rather than proving it.

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
- Close the 2 sorry sites at ChronicleConstruction.lean:1598,1633
- Revert `BurgessR3Maximal` to SDC-maximality and remove false `NoUnivBurgessR3` hypothesis to make `bx_completeness` unconditional
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
| SDC-maximality revert: `BurgessR3Maximal_extension_fails` needs inconsistent-DC case handling | Delays Phase 7 | Medium | When DC(B∪{δ}) is inconsistent, ⊢ β₀→¬δ for some β₀∈B, so the seed consistency proof simplifies (∼δ is redundant). Alternatively, add consistency precondition and fix ~5 callers. |
| h_nubr3 removal touches ~733 references across 7 files | Extended effort | Low | Mechanical: search for `h_nubr3` parameter in signatures and call sites, delete. Build-error-driven iteration. |
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

### Phase 4: Fix C5 Forward Cases with Walk Restructuring [COMPLETED]

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
- [x] **Task 4.1**: Fix **not-actual case** (CE:1476-1480): Stop discarding guard witness. Changed `h_actual` condition to use adjacent-pair guard instead of pointwise guard. Push_neg gives the guard directly. Fixed h_no_wit usage to construct adjacent-pair guard from pointwise guard. **DONE**: h_actual strengthened, push_neg gives guard, not-actual case compiles.
- [x] **Task 4.2**: Fix **n=0 case** (CE near 848): Switched `lemma_2_4` → `lemma_2_4_with_guard` to get `xi ∈ B`. Added guard proof: only adjacent pair (a,b) with pc.x ≤ a, b ≤ y is (max_old, y), and g'(max_old, y) = B with ξ ∈ B. **DONE**: ~30 lines added for guard proof.
- [x] **Task 4.3**: Fix **Walk A, pc.x = max_old**: Absorbed into walk helper base case. **DONE**.
- [x] **Task 4.4**: **RESTRUCTURE Walk A, pc.x < max_old**: Replaced the walk-to-max_old logic with direct splitting at (pc.x, x'). When condition (i) holds: `xi ∈ g(pc.x, x')` and `xi∧U(xi,η) ∈ f(x')` and `η ∉ f(x')`. This is the splitting setup — apply lemma_2_7/2_8/2_6 at (pc.x, x'). The splitting produces z = midpoint(pc.x, x') with g'(pc.x, z) = B' ⊇ g(pc.x, x') ∋ xi. The witness z is adjacent to pc.x. **DONE**: ~80 lines added.
- [x] **Task 4.5**: **REMOVE Walk B eta-shortcut**: Deleted with Walk A+B code. **DONE**. Was (CE:994-997): Delete the branch that returns χ unchanged when `η ∈ f(u_next)`. Always fall through to splitting at (u_max, u_next). ~-20 lines (deletion).
- [x] **Task 4.6**: Fix **Walk B splitting** (after removing shortcut): Split at (u_max, u_next). Case on `xi ∈ g(u_max, u_next)`:
  - If yes: g ⊆ B' from splitting gives `xi ∈ B'`. Guard at both adjacent pairs.
  - If no: strengthened `lemma_2_7` (Phase 2) gives `xi ∈ B'` directly.
  **DONE**: ~40 lines added.
- [x] **Task 4.7**: Fix **not-condition(i) splitting cases**: Added `pc.ξ ∈ B'` to h_split_result return type. Updated all 6 sub-cases: cases with xi ∈ g use `g ⊆ B'`; cases with xi ∉ g use strengthened `lemma_2_7` return. Added `by_cases h_xi_g6` sub-split in case 6 (eta.neg ∉ g). Guard proof in c5_forward_witness: only adj pair (pc.x, z), g'(pc.x, z) = B', ξ ∈ B'. **DONE**: ~40 lines added.
- [x] **Task 4.8**: Run `lake build` to verify all C5 forward cases compile with adjacent-pair guard. **PASSED**.

**Timing**: 6-8 hours (actual: ~7h)

**Depends on**: 3

**Files modified**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- all C5 forward case construction sites

**Verification**:
- [x] All C5 forward case constructions compile with adjacent-pair guard
- [x] No sorry introduced in CE
- [x] Walk A restructured (walk-to-max_old logic replaced)
- [x] Walk B eta-shortcut removed
- [x] `lake build` passes (C5 backward errors remain, fixed in Phase 5)

---

### Phase 5: Fix C5 Backward (Since) Cases [COMPLETED]

**Goal**: Mirror Phase 4 for all C5 backward (Since) case constructions. Apply the same restructuring (walk → split, remove eta-shortcut, thread guard through splitting).

**Paper reference**: Burgess C5b (Since mirror of C5a). All arguments are symmetric.

**Tasks**:
- [x] **Task 5.1**: Fix **not-actual since case**: Stop discarding guard, mirror of Phase 4 Task 4.1. ~10-15 lines.
- [x] **Task 5.2**: Fix **backward n=0 case**: Switch to `lemma_2_4_since_with_guard` (Since variant created in PointInsertion.lean). ~120 lines for new lemma + ~80 lines for n=0 case.
- [x] **Task 5.3**: **RESTRUCTURE backward Walk A** (pc.x > min_old): Created `c5_backward_walk` recursive function mirroring `c5_forward_walk`. Replaced ~350 lines of Walk A + Walk B with single call. ~300 lines for new function + ~15 lines for call site.
- [x] **Task 5.4**: **REMOVE backward Walk B eta-shortcut**. Removed entirely (replaced by `c5_backward_walk`).
- [x] **Task 5.5**: Fix **backward Walk B splitting**. Handled by `c5_backward_walk` split case.
- [x] **Task 5.6**: Fix **backward not-condition(i) splitting cases**. Added `pc.ξ ∈ B''` to h_split_result (8th component), fixed witness_guard proof. ~50 lines.
- [x] **Task 5.7**: Run `lake build` to verify all CounterexampleElimination.lean compiles clean. BUILD PASSES.

**Timing**: 4-6 hours

**Depends on**: 3

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` -- C5 backward case sites

**Verification**:
- All C5 backward case constructions compile with adjacent-pair guard
- CounterexampleElimination.lean has 0 sorry sites
- `lake build` passes

---

### Phase 6: Strengthen omega_chain_c5_witness and Close 2 Sorries [COMPLETED]

**Goal**: Strengthen `omega_chain_c5_witness` (ChronicleConstruction.lean:392) to return the adjacent-pair guard from the elimination stage, then close the 2 sorry sites at lines 1598 and 1633 using `adj_g_mem_limit_f`.

**Paper reference**: Burgess 2.11 (truth lemma, p.375). The full C5a with guard: `U(ξ,η) ∈ limit_f(x) → ∃ y, η ∈ limit_f(y) ∧ ξ ∈ limit_g(x,y)`.

**Tasks**:
- [x] **Task 6.1**: Strengthen `omega_chain_c5_witness` return type (CC:392-399) to include `∧ ∀ a b, Adjacent (omega_chain_val ...).dom a b → pc.x ≤ a → b ≤ y → pc.ξ ∈ (omega_chain_val ...).g a b`. This follows directly from the strengthened `EliminationResult.c5_forward_witness`. **DONE**: `omega_chain_c5_witness` now returns `⟨y, hy_dom, hxy, hy_η, h_adj_guard, h_dom_guard⟩` with adjacent-pair guard and domain guard.
- [x] **Task 6.2**: Strengthen `omega_chain_c5'_witness` (CC:418-438) similarly for Since. **DONE**: `omega_chain_c5'_witness` mirrored with `h_adj_guard` and `h_dom_guard`.
- [x] **Task 6.3**: Prove `limit_satisfies_c5_strong` guard step (CC:1445 → now CC:1598). The proof:
  1. From strengthened `omega_chain_c5_witness`, obtain `∀ a b, Adjacent dom_{n+1} a b → pc.x ≤ a → b ≤ y → ξ ∈ g_{n+1}(a,b)` where y is the C5 witness at stage n+1.
  2. For any w ∈ limit_dom with x < w < y: w was inserted at some stage m ≥ n+1. At stage m, w sits between some adjacent pair (a,b) at stage n+1 with x ≤ a and b ≤ y.
  3. Apply `adj_g_mem_limit_f` (CC:1406): `ξ ∈ g_{n+1}(a,b)` → `ξ ∈ limit_f(w)`.
  **PARTIAL**: Main proof structure complete. **SORRY** remains at line 1598 in the sub-case where `y ∈ dom_n` and `w ∈ dom_{n+1} \ dom_n`. This sub-case requires a new lemma `omega_chain_no_new_when_witness_old` (see Phase 6 notes below).
- [ ] **Task 6.4**: Close `limit_satisfies_c5'_strong` guard sorry (CC:1457 → now CC:1633). Mirror of Task 6.3 for Since. **PENDING**: Blocked on same `omega_chain_no_new_when_witness_old` lemma as Task 6.3.
- [ ] **Task 6.5**: Run `lake build` and `grep -rn "sorry" Chronicle/` to verify 0 sorry sites on critical path. **PENDING**: Currently 2 sorries remain.

**Blocker / New Work Identified**:
The sorry at CC:1598 (and its mirror at 1633) occurs in the sub-case `y ∈ dom_n ∧ w ∈ dom_{n+1} \ dom_n`. The reasoning is:
- If `y ∈ dom_n`, then the C5 counterexample was already resolved at stage n, so the elimination at stage n should be identity (no new points added).
- Therefore `dom_{n+1} = dom_n`, contradicting `w ∈ dom_{n+1} \ dom_n`.
- **Missing lemma needed**: `omega_chain_no_new_when_witness_old` (or similar), stating that when the witness y is already in `dom_n`, `omega_chain_val (n+1)` adds no new points.

**Timing**: 2-3 hours (Task 6.1–6.2 done; Tasks 6.3–6.5 blocked)

**Depends on**: 4, 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` -- omega_chain_c5_witness, limit_satisfies_c5_strong, Since mirrors

**Verification**:
- Both sorry sites at CC:1598 and CC:1633 are closed
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns only comment/doc occurrences
- `lake build` passes

---

### Phase 7: Revert BurgessR3Maximal to SDC-Maximality and Remove NoUnivBurgessR3 [IN PROGRESS]

**Goal**: Make `bx_completeness` unconditional by reverting `BurgessR3Maximal` to SDC-maximality and removing the false `NoUnivBurgessR3` hypothesis from all signatures.

**Paper reference**: Burgess 1982's R(A, B, C) uses maximality over all DCSs (p.371). His construction tacitly assumes relevant extensions are consistent. The code's CUD-maximality was an over-strengthening that required `NoUnivBurgessR3` as compensation — but this hypothesis is false in J₀ (`burgessR3(A, Set.univ, C)` is satisfiable in discrete orders under open-guard semantics). SDC-maximality matches the actual mathematical content: the Zorn family consists of SDC sets, and the maximal element is SDC-maximal.

**Tasks**:
- [ ] **Task 7.1**: Change `BurgessR3Maximal` definition (ChronicleTypes.lean:351-354): replace `ClosedUnderDerivation D` with `SetDeductivelyClosed D` in the maximality clause. Keep first conjunct `ClosedUnderDerivation B` unchanged.
- [ ] **Task 7.2**: Delete `NoUnivBurgessR3` definition (ChronicleTypes.lean:366-368).
- [ ] **Task 7.3**: Simplify Zorn construction `burgessR3Maximal_extension_exists` (RRelation.lean:~756-808): remove `h_no_univ` parameter and the inconsistent-D case at lines 805-808.
- [ ] **Task 7.4**: Fix `BurgessR3Maximal_extension_fails` (PointInsertion.lean:642-655): add consistency precondition or handle inconsistent-DC case separately. When DC(B∪{δ}) is inconsistent, the seed consistency proof simplifies (∼δ follows from B).
- [ ] **Task 7.5**: Remove `h_nubr3 : NoUnivBurgessR3` from all signatures across 7 files (~733 references). Mechanical search-and-replace.
- [ ] **Task 7.6**: Remove `h_nubr3` from `bx_completeness` (Completeness.lean:128), making it unconditional.
- [ ] **Task 7.7**: Run `lake build`, `grep -rn "NoUnivBurgessR3\|h_nubr3" Theories/`, `#print axioms bx_completeness`.

**Timing**: 4-8 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` — definition change + deletion
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` — Zorn construction simplification
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` — extension_fails fix + h_nubr3 removal
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` — h_nubr3 removal
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` — h_nubr3 removal
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` — h_nubr3 removal
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — unconditional bx_completeness

**Verification**:
- `NoUnivBurgessR3` no longer exists in codebase (only comments)
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

- [x] `lake build` succeeds at every phase boundary (Phases 1–5 verified)
- [ ] `#print axioms bx_completeness` -- no `sorryAx` after Phase 7
- [ ] `grep -rn "sorry" Chronicle/` -- only comment/doc after Phase 6 (currently 2 sorries remain at CC:1598,1633)
- [ ] After Phase 9: convention matches Burgess U(event, guard)
- [x] No density or discreteness axioms added (verified through Phase 5)
- [x] `irr_until` axiom NOT used (verified through Phase 5)
- [x] All new lemmas follow Burgess 1982 exactly -- no novel approaches (verified through Phase 5)
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

- **Phase 7 (SDC-maximality revert)**: Mostly mechanical (removing ~733 h_nubr3 references). The mathematical change is in `BurgessR3Maximal_extension_fails` — if the inconsistent-DC case handling proves difficult, fall back to adding a consistency precondition and fixing callers individually.

- **Phase 9 (convention migration)**: Separate commit for clean revert. Silent corruption is the main risk. The audit in Task 9.9 is critical.

- **General**: Commit after each phase. `git revert` at any phase boundary.
