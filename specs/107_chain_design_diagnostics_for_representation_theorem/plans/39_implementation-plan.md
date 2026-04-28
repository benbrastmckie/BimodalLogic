# Implementation Plan: Task #107 — Burgess Chronicle Construction (Post-113, Corrected Approach)

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Status**: [NOT STARTED]
- **Effort**: 52 hours
- **Dependencies**: Task 113 [COMPLETED] (open-guard semantics)
- **Research Inputs**: [reports/39_team-research.md], [reports/38_team-research.md]
- **Artifacts**: plans/39_implementation-plan.md (this file)
- **Standards**: plan-format.md, status-markers.md, artifact-management.md, tasks.md
- **Type**: lean4
- **Lean Intent**: true

## Overview

The 11 chronicle sorry sites all trace to 3 deviations from the published Burgess 1982/Xu 1988 proofs: (1) wrong C4 elimination strategy (rightmost point instead of induction + BX6 substitution), (2) wrong C5 formulation (guard in f(z) instead of g(x,y)), and (3) incomplete C5 elimination (only n=0 case, deferred g-values). This plan replaces the prior plan (v21, artifact 34) which is completely invalidated by these findings. The approach is to clean up dead code from the closed-guard era and mistaken approaches, then faithfully implement Burgess/Xu's constructions following the open-guard semantics established by task 113. Definition of done: `dd_countermodel_chronicle` is sorry-free, `#print axioms` shows no `sorryAx`, `lake build` succeeds.

### Research Integration

- **Report 39 (team research, 4 teammates, unanimous)**: Primary input. Identified the 3 root deviations causing all 11 sorry sites. Mapped each sorry to its paper-based fix. Confirmed B_sub_A was never part of the construction, nested bridging is solved by formula substitution, FUC is trivial once C5 is reformulated.
- **Report 38 (team research, 4 teammates)**: Confirmed B_sub_A irrecoverable, nested bridging unprovable under open guard, FUC harder than initially estimated. Corrected sorry count to 30 total (11 chronicle + 15 non-chronicle + 4 algebraic).
- **Prior plan v21 (artifact 34)**: Invalidated. Lesson: the D0 seed construction approach depended on B_sub_A which is provably false under open guard. The absorption-based splitting was wrong direction (parts-to-whole, not whole-to-parts).

### Prior Plan Reference

Plan v21 (artifact 34) is completely invalidated. Key lessons: (1) B_sub_A_of_burgessR3 is irrecoverable under open guard -- never attempt again; (2) burgessR3_absorption is Lemma 2.5 (composition), not splitting; (3) the D0 consistency proof strategy that depended on B_sub_A must be replaced by Xu's Lemma 3.2.1 approach; (4) rRelation is a codebase invention not found in any paper.

### Roadmap Alignment

- Advances: "TM is complete with respect to TaskFrames over totally ordered abelian groups" (representation theorem)
- Chronicle pathway is the primary completeness path (ROADMAP Section: Active Metalogic Paths)
- Closing all 11 chronicle sorry sites achieves the chronicle sorry-free milestone
- ROADMAP needs updating to reflect the corrected approach (open-guard, Burgess/Xu faithful implementation)

## Goals & Non-Goals

**Goals**:
- Clean up dead code from closed-guard era and mistaken approaches (archive to Boneyard, delete sorry stubs)
- Upgrade C2' to require BurgessR3Maximal (matching Burgess's R-maximality requirement)
- Restructure C4 elimination to use induction on intermediate points + BX6 formula substitution (Burgess Lemma 2.9)
- Reformulate C5 to put guard in g(x,y) instead of individual f(z) (Burgess C5a)
- Implement full C5 elimination with Lemma 2.7/2.8 insertion and eager g-value assignment (Burgess Lemma 2.10)
- Implement Xu's Lemma 3.2.1 (B closure under Until/Since formation) as D0 replacement
- Close all 11 chronicle sorry sites
- Update ROADMAP.md to reflect corrected approach
- Achieve sorry-free `dd_countermodel_chronicle`
- Maintain `lake build` at each phase boundary

**Non-Goals**:
- BXCanonical sorry closure (task 109)
- Algebraic path sorries (InteriorOperators.lean, TenseS5Algebra.lean)
- Reviving B_sub_A or D0 consistency approach (proved irrecoverable)
- Keeping rRelation as primary r-relation concept (use burgessR3/BurgessR3Maximal only)
- Adding density axioms (GGp->Gp is not derivable in BX)
- Implementing A4a (not in our axiom system; use Xu's approach instead)

## Risks & Mitigations

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| C5 reformulation cascading effects on limit_satisfies_c5, truth lemma, and other C5-dependent proofs | H | H | Scope the cascading changes carefully in Phase 4; the truth lemma becomes trivial (C5 + C3 = guard at all intermediate points) |
| Lemma 2.7/2.8 (insertion between existing points) engineering complexity in Lean | H | M | Start with careful paper-to-code mapping; existing PointInsertion infrastructure is sorry-free and provides patterns |
| Xu's Lemma 3.2.1 requires non-trivial BX5 + maximality argument | M | M | BX5 (self_accum) and BurgessR3Maximal infrastructure are sorry-free; follow Xu's proof step by step |
| Cleanup phase accidentally removes code that is still needed | M | L | Archive to Boneyard rather than delete; run `lake build` after each removal |
| C4 induction step requires careful formula tracking through BX6 | M | M | Both Burgess and Xu describe the exact same substitution; BX6 (absorb_until) is available |
| rRelation removal breaks non-chronicle code | L | L | rRelation is only used in chronicle files; check imports before archiving |

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

Phases 3 and 4 can execute in parallel (independent files). All other phases are sequential.

---

### Phase 1: Review and Snapshot ROADMAP.md [NOT STARTED]

**Goal**: Record the current state of ROADMAP.md before any changes, identifying which items this task will advance and documenting the before-state for comparison.

**Tasks**:
- [ ] Read current ROADMAP.md and record its sorry inventory (chronicle: 12 sorry sites across 4 files as currently documented)
- [ ] Identify stale claims: ROADMAP says "13 sorry sites remain across 4 files" for chronicle, but actual count is 11 (2 in RRelation, 7 in CounterexampleElimination, 2 in ChronicleToCountermodel)
- [ ] Note items to update: Chronicle module structure line counts, sorry inventory table, C4/C5 descriptions, current strategy section, priority order
- [ ] Record which roadmap items this task advances: primary completeness path, representation theorem goal

**Timing**: 0.5 hours

**Depends on**: none

**Files to modify**:
- None (read-only snapshot)

**Verification**:
- Notes captured for Phase 8 ROADMAP update

---

### Phase 2: Cleanup — Archive Dead Code and Delete Sorry Stubs [NOT STARTED]

**Goal**: Remove dead code from the closed-guard era and mistaken approaches before rebuilding. Archive recoverable code to Boneyard, delete provably invalid sorry stubs.

**Tasks**:
- [ ] Delete nested bridging sorry stubs from RRelation.lean (lines ~1165-1191): `burgessR3_gamma_not_in_B_nested` and `burgessR3_gamma_not_in_B_since_nested`. These require BX9 which was removed in task 113.
- [ ] Archive B_sub_A infrastructure to `Boneyard/ClosedGuardLegacy/` (if any remains outside Boneyard): `B_sub_A_of_burgessR3`, `burgess_D0_elem_in_A_or_C`, `burgess_D0_consistent` (partial). Check PointInsertion.lean for D0-related code.
- [ ] Remove or archive rRelation-based code that is not needed: assess which rRelation lemmas are used by non-chronicle code before removing. The `rRelation` definition and `rRelation_guard_continues'` should be preserved if used elsewhere, but flagged as secondary.
- [ ] Update c2 definition in ChronicleTypes.lean to use `burgessR3` instead of `r3Relation` (if currently using r3Relation)
- [ ] Update stale documentation in Completeness.lean (internal docs claiming wrong sorry counts)
- [ ] Run `lake build` to verify no regressions

**Timing**: 2 hours

**Depends on**: 1

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` — delete nested bridging stubs (~30 lines removed)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` — update c2 definition
- `Theories/Bimodal/Boneyard/ClosedGuardLegacy/` — archive destination for B_sub_A code
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — update stale sorry count comments

**Verification**:
- `lake build` succeeds
- `grep -r "burgessR3_gamma_not_in_B_nested" Theories/` returns nothing
- No new sorry sites introduced

---

### Phase 3: Upgrade C2' to BurgessR3Maximal and Implement Xu's Lemma 3.2.1 [NOT STARTED]

**Goal**: Upgrade the c2' chronicle condition to require BurgessR3Maximal (matching Burgess's R-maximality in C2'), and implement Xu's Lemma 3.2.1 as the replacement for the failed B_sub_A/D0 approach.

**Tasks**:
- [ ] Upgrade c2' field in ChronicleTypes.lean to require `BurgessR3Maximal` instead of just `burgessR3`. The `burgessR3Maximal_exists_from_seed` infrastructure (RRelation.lean:1131, sorry-free) already produces maximal DCSs.
- [ ] Implement Xu's Lemma 3.2.1: `BurgessR3Maximal A B C → β ∈ B → γ ∈ C → untl(γ, β) ∈ B` (B closure under Until/Since formation). Uses BX5 (self_accum) + maximality.
- [ ] Implement the Since mirror: `BurgessR3Maximal A B C → β ∈ B → α ∈ A → snce(β, α) ∈ B`
- [ ] Update all existing c2' construction sites to use the upgraded type (may require adding maximality proofs where only burgessR3 was provided)
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` — upgrade c2' definition (~20 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/RRelation.lean` — add Xu Lemma 3.2.1 (~80 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` — update type signatures (~30 lines)

**Verification**:
- Xu's Lemma 3.2.1 compiles sorry-free
- c2' type uses BurgessR3Maximal
- `lake build` succeeds (sorry sites may increase temporarily as type changes cascade)

---

### Phase 4: Restructure C4 Elimination (Burgess Lemma 2.9) [NOT STARTED]

**Goal**: Replace the "rightmost point + bridging lemma" C4 elimination strategy with Burgess's induction on intermediate point count + BX6 formula substitution. This closes the 2 nested bridging sorry sites and the 2 C4-related c2' sorry sites.

**Tasks**:
- [ ] Implement C4 elimination induction structure: induction on n = number of domain points between x and y
- [ ] Base case (n=0, adjacent pair): Apply Lemma 2.6 directly with BurgessR3Maximal splitting. Construct fresh MCS D with neg(delta) in D, plus B', B'' with BurgessR3Maximal for new pairs.
- [ ] Inductive step (n=m+1): Let x' be the immediate successor of x.
  - Sub-case: neg_U(gamma, delta) in f(x') — reduce to n=m by replacing x with x'
  - Sub-case: U(gamma, delta) in f(x') — apply BX6 formula substitution: set gamma' = delta AND U(gamma, delta), derive neg_U(gamma', delta) in f(x) via BX6 contrapositive, reduce to base case (0 intermediate points between x and x')
- [ ] Construct g-values for new adjacent pairs via `burgessR3Maximal_exists_from_seed` at each splitting step
- [ ] Mirror for C4' (Since direction)
- [ ] Delete the old C4 elimination code that used nested bridging
- [ ] Run `lake build`

**Timing**: 12 hours

**Depends on**: 2

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` — rewrite C4/C4' elimination (~200 lines rewritten)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` — may need helper lemmas for BX6 substitution step (~30 lines)

**Verification**:
- C4 elimination compiles without sorry for the 2 C4-related c2' sites (CounterexampleElimination.lean:864, 902)
- Nested bridging stubs are no longer called
- `lake build` succeeds

---

### Phase 5: Reformulate C5 and Implement Full Elimination (Burgess Lemma 2.10) [NOT STARTED]

**Goal**: Reformulate C5 to put guard in g(x,y) (matching Burgess C5a), implement the full C5 elimination induction with Lemma 2.7/2.8 for insertion between existing points, and assign g-values eagerly. This closes the 6 c2' sorry sites and the 1 density sorry.

**Tasks**:
- [ ] Reformulate C5 definition in ChronicleTypes.lean: change from "guard gamma in f(z) for each domain point z" to "guard eta in g(x,y)" where g(x,y) is the interval DCS
- [ ] Implement Lemma 2.7 (PointInsertion.lean): insert a new point z between existing points x and y, constructing f(z) and g-values for (x,z) and (z,y) from the existing g(x,y)
- [ ] Implement Lemma 2.8 (mirror of 2.7 for the Since direction)
- [ ] Rewrite C5 elimination with full induction on n = number of domain points after x:
  - Case n=0: Apply Lemma 2.4 to place new y after x. Set g(x,y) = B where eta in B via `burgessR3Maximal_exists_from_seed`. Assign g-values eagerly.
  - Case n=m+1: Let x' be the successor of x. Use Lemma 2.7 to insert z between x and x', with eta in g(x,z).
- [ ] Mirror for C5' (Since direction) using Lemma 2.8
- [ ] Fix density elimination: replace `f(z) = f(x)` approach with proper insertion using Lemma 2.7. The new point z gets a fresh MCS from the insertion lemma, not a copy of f(x).
- [ ] Update g_prop/h_prop elimination to use proper g-value construction (or remove if subsumed by C4/C5 with proper g-values)
- [ ] Propagate C5 reformulation to all dependent proofs (limit_satisfies_c5, etc.)
- [ ] Run `lake build`

**Timing**: 18 hours

**Depends on**: 3, 4

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleTypes.lean` — reformulate C5 definition (~30 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/PointInsertion.lean` — add Lemma 2.7/2.8 (~150 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/CounterexampleElimination.lean` — rewrite C5/C5'/density elimination (~300 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` — update limit proofs for new C5 formulation (~50 lines)

**Verification**:
- All 7 c2' sorry sites closed (CounterexampleElimination.lean:786, 824, 864, 902, 938, 970, 1086)
- C5 definition uses g(x,y) for guard placement
- `lake build` succeeds

---

### Phase 6: Close FUC Sorry Sites (Truth Lemma) [NOT STARTED]

**Goal**: Close the 2 remaining sorry sites in ChronicleToCountermodel.lean (restricted_fuc for Until and Since). With the corrected C5 (guard in g(x,y)) and C3 (g(x,y) subset f(z)), the truth lemma for Until becomes trivial.

**Tasks**:
- [ ] Prove `cantor_bfmcs_restricted_fuc` (Until direction, line ~615): For U(beta, gamma) in f(x), C5a gives y with beta in f(y) and gamma in g(x,y). For any z between x and y, C3 gives g(x,y) subset f(z), so gamma in f(z). The guard holds at all intermediate points.
- [ ] Prove mirror for Since direction (line ~619)
- [ ] Verify that g-immutability across omega-chain stages (old pairs preserve g-values) follows from the elimination function's g_agrees fields
- [ ] Run `lake build`

**Timing**: 6 hours

**Depends on**: 5

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleToCountermodel.lean` — close 2 FUC sorry sites (~60 lines)
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/ChronicleConstruction.lean` — may need g-immutability lemma (~30 lines)

**Verification**:
- Both FUC sorry sites closed
- `dd_countermodel_chronicle` compiles sorry-free
- `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- `lake build` succeeds

---

### Phase 7: Integration and Validation [NOT STARTED]

**Goal**: Verify the full sorry-free chronicle path, run axiom audits, and ensure the representation theorem chain is complete.

**Tasks**:
- [ ] Run `#print axioms dd_countermodel_chronicle` and verify no `sorryAx`
- [ ] Run `#print axioms bx_completeness` (via Completeness.lean delegation) — note: this may still show sorries from BXCanonical path if both paths are wired
- [ ] Verify `lake build` succeeds with no warnings related to chronicle files
- [ ] Run a full grep for `sorry` across all Chronicle/ files to confirm zero sorry sites
- [ ] Update Completeness.lean to document the sorry-free chronicle path status
- [ ] Clean up any temporary scaffolding or commented-out code from the implementation

**Timing**: 2 hours

**Depends on**: 6

**Files to modify**:
- `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` — all files (cleanup)
- `Theories/Bimodal/Metalogic/BXCanonical/Completeness.lean` — update documentation

**Verification**:
- `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns empty
- `lake build` succeeds
- `#print axioms` clean

---

### Phase 8: Update ROADMAP.md [NOT STARTED]

**Goal**: Update ROADMAP.md to reflect the completed chronicle construction, corrected approach, and current state of the completeness effort.

**Tasks**:
- [ ] Update chronicle sorry inventory: mark all 11 sorry sites as resolved with completion annotation *(Completed: Task 107, 2026-MM-DD)*
- [ ] Update "Current Strategy" section to describe the faithful Burgess/Xu implementation with open-guard semantics
- [ ] Correct stale claims: update sorry counts, file line counts, module structure description
- [ ] Update C4 description: induction + BX6 formula substitution (not rightmost point + bridging)
- [ ] Update C5 description: guard in g(x,y) (not individual f(z))
- [ ] Add note about Xu's Lemma 3.2.1 replacing the D0/B_sub_A approach
- [ ] Mark chronicle construction items with `- [x]` where completed
- [ ] Update "Recommended Priority Order" to reflect chronicle completion
- [ ] Add any new items discovered during implementation

**Timing**: 1.5 hours

**Depends on**: 7

**Files to modify**:
- `specs/ROADMAP.md` — comprehensive update (~100 lines modified)

**Verification**:
- ROADMAP sorry inventory matches actual codebase state
- All completed items marked with `- [x]` and completion annotations
- No stale claims remain in chronicle-related sections

---

## Testing & Validation

- [ ] `lake build` succeeds at each phase boundary
- [ ] `grep -rn "sorry" Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` returns empty after Phase 7
- [ ] `#print axioms dd_countermodel_chronicle` shows no `sorryAx`
- [ ] All previously sorry-free lemmas remain sorry-free (no regressions)
- [ ] Nested bridging stubs are fully removed from codebase
- [ ] C5 definition matches Burgess C5a (guard in g(x,y))
- [ ] C2' requires BurgessR3Maximal
- [ ] Xu's Lemma 3.2.1 compiles sorry-free

## Artifacts & Outputs

- `plans/39_implementation-plan.md` (this file)
- Modified Chronicle files (6 files in `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/`)
- Archived dead code in `Theories/Bimodal/Boneyard/ClosedGuardLegacy/`
- Updated `specs/ROADMAP.md`
- Sorry-free `dd_countermodel_chronicle`

## Rollback/Contingency

- All dead code is archived to Boneyard (not deleted), enabling recovery
- Git history preserves all prior states; `git log --oneline Theories/Bimodal/Metalogic/BXCanonical/Chronicle/` traces changes
- If C5 reformulation cascading effects are larger than expected, the old C5 can be restored from git and the reformulation attempted more incrementally
- If Lemma 2.7/2.8 engineering proves harder than estimated, a fallback is to implement only the n=0 case (which already exists in the codebase) and handle remaining cases with targeted sorry stubs for future phases
- The BXCanonical path (task 109) remains as an independent backup completeness route
