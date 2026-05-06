# Teammate D (Horizons): Strategic Work Inventory and Sequencing

## Key Findings

### 1. Comprehensive Sorry Inventory (Active Code)

**Total: 42 sorry sites across 10 active files** (excluding Boneyard/41 files, Examples)

#### A. Critical Path — Chronicle Construction (2 sorries, 1 file)

| File | Line | Definition | Root Cause |
|------|------|-----------|------------|
| ChronicleConstruction.lean | 1445 | `limit_satisfies_c5_strong` | Guard ξ ∈ limit_g(x,y) — needs base case from Burgess C5a alignment |
| ChronicleConstruction.lean | 1457 | `limit_satisfies_c5'_strong` | Since mirror of above |

**Status**: Plan v63, Phase 3 Tasks 3.7-3.8 are the blockers. Plan v63 Phase 3.7 has identified the root cause: `lemma_2_7` needs `xi ∈ B'` via DC(B ∪ {xi}) seed, and `h_actual` must use g-values per Burgess C5a. These correspond to handoffs `burgess-c5a-alignment.md` and `dom-unique-done-guard-analysis.md`.

#### B. Secondary Path — BXCanonical (18 sorries, 7 files, becomes dead code after Chronicle)

| File | Count | Category | Notes |
|------|-------|----------|-------|
| RootScopedChain.lean | 3 | Critical (for BXCanonical path) | Blocked by Lindenbaum opacity; dead once Chronicle succeeds |
| Quasimodel/Realization.lean | 4 | Irreflexive-consequence | F_of_mem, P_of_mem, seed proofs |
| Filtration/SigmaOrdering.lean | 3 | Irreflexive-consequence | sigma_le_refl, sigma_strict_irrefl, not_sigma_equiv |
| Quasimodel/Construction.lean | 2 | Irreflexive-consequence | refl_intro_until/since_mcs |
| TruthLemma.lean | 2 | Irreflexive-consequence | until/since_backward_refl_mcs |
| Frame.lean | 1 | Intentionally invalid | bx_le_refl (no longer valid under irreflexive semantics) |

**Note**: CanonicalModel.lean now has 0 sorries (was 2 in ROADMAP — stale). ROADMAP says 19 BXCanonical sorries but actual count is 15 (3 RootScopedChain + 12 irreflexive-consequence + 0 CanonicalModel).

#### C. Bundle Layer (6 sorries, 2 files, NOT on critical path)

| File | Count | Notes |
|------|-------|-------|
| Bundle/SuccExistence.lean | 3 | Not imported by BXCanonical or Chronicle |
| Bundle/SuccRelation.lean | 3 | Not imported by BXCanonical or Chronicle |

These are legacy sorry sites that predate the current architecture. Not blocking anything.

#### D. Theorems Layer (19 sorries, 1 file, partially on critical path)

| File | Count | On Critical Path? | Notes |
|------|-------|-------------------|-------|
| Theorems/TemporalDerived.lean | 19 | **2 latent** | `psi_imp_until` and `psi_imp_since` are called by `UntilSinceCoherence.lean:backward_until_reflexive/backward_since_reflexive`, but those definitions are NOT used by Chronicle. 17 others are unused. |

**Important caveat**: `TemporalDerived.lean` is imported by RRelation.lean and PointInsertion.lean. While the sorry'd definitions themselves aren't called on the critical path, the file's import brings `sorryAx` into scope. **Need to verify**: does `#print axioms bx_completeness` currently show `sorryAx` from TemporalDerived even if the sorry'd defs aren't called? Lean 4 is lazy about this — only definitions actually used contribute axioms. So probably safe, but worth auditing.

**Validity note**: Many of these 19 sorry'd theorems are NOT VALID under irreflexive semantics:
- `density_derivable` (GGφ → Gφ) — requires density, not derivable in BX
- `psi_imp_until` (ψ → φUψ) — NOT valid under irreflexive semantics (needs strict future witness)
- `refl_F`, `refl_P` — NOT derivable without BX1
- `bot_until_elim`, `bot_since_elim` — depended on removed BX9
These should be either deleted or marked as invalid rather than left as sorry stubs.

#### E. Boneyard (estimated 40+ sorries, 41 files, 1.4MB)

Archived dead code. Expected. No action needed unless cleanup is desired.

#### F. Examples (estimated 10+ sorries)

Pedagogical/demo files. Expected and intentional.

### 2. Stale Documentation Inventory

| Document | What's Stale | Actual State |
|----------|-------------|--------------|
| **ROADMAP.md** (line 27-28) | "9 sorry sites remain on critical path across 2 files" | **2 sorries in 1 file** (ChronicleConstruction.lean only) |
| **ROADMAP.md** (line 32-34) | "19 sorry proofs across 7 files... Chronicle has 9 sorry proofs on critical path" | Chronicle has **2** on critical path, **0** in other Chronicle files |
| **ROADMAP.md** (line 54-63) | Sorry table: 5 c2' + 2 C4 + 2 FUC = 9 sorries | **All c2' and C4 sorries are closed**. Only 2 FUC guard sorries remain. |
| **ROADMAP.md** (line 62) | "6 NoUnivBurgessR3 stubs in PointInsertion.lean" | NoUnivBurgessR3 stubs produce 0 sorry sites (the 7 references are to the definition/type, not sorry) |
| **ROADMAP.md** (lines 316-322) | Chronicle state description references 9 sorries | 2 sorries |
| **Completeness.lean** (lines 189-195) | "11 total, on critical path: 7 c2' + 2 c4 + 2 FUC" | **2 FUC guard sorries only** |
| **ROADMAP.md** (line 375) | "CanonicalModel.lean (~440 lines, 2 sorries)" | **0 sorries** |
| **ROADMAP.md** (lines 1119-1122) | Phase 4-6 TODO items (NoUnivBurgessR3, EliminationResult, C4/C4') | All completed |

### 3. Convention Migration Scope

From report 67: 33 active files, ~2,141 references (1,164 untl + 977 snce). The "elegant approach" swaps semantics at Truth.lean (2 lines) then cascades through axioms and definitions. The burgessR definition needs its argument order swapped too, cascading through all Chronicle code.

**Key risk**: Both args are `Formula` type — missed swaps compile silently but corrupt logic.

### 4. Infrastructure Gaps (from handoffs)

| Gap | Source | Description | Effort |
|-----|--------|-------------|--------|
| `xi ∈ B'` in lemma_2_7 | burgess-c5a-alignment.md | Zorn seed DC(B ∪ {xi}) instead of DC({xi}) | ~30 lines |
| h_actual g-value check | report 68 | Counterexample check must use g-values per Burgess C5a | ~230 lines |
| Guard base case proof | Plan v63 Task 3.7 | C5 guard base case: ξ ∈ g_{n+1}(x, y) | ~50 lines |
| limit guard closure | Plan v63 Task 3.8 | Close 2 sorries using adj_g_mem_limit_f | ~20 lines |

### 5. Dead Code / Cleanup Candidates

| Item | Location | Size | Action |
|------|----------|------|--------|
| 19 invalid sorry stubs | TemporalDerived.lean | 19 defs | Delete or mark invalid (17 unused, 2 latent) |
| NoUnivBurgessR3 definition | ChronicleTypes.lean:366 | Used as param throughout | Keep (structural assumption) |
| 6 Bundle sorry sites | SuccExistence/SuccRelation | 6 sorries | Not blocking; cleanup optional |
| 41 Boneyard files | Boneyard/ | 1.4MB | Already archived; no action |

---

## Recommended Sequencing

### Wave 1: Close Critical Path (MUST DO FIRST)

**Dependencies**: Plan v63 Tasks 3.7 → 3.8 → 4.3/4.4 → 5.4-5.7

1. **Task 3.7**: Implement the Burgess C5a alignment fixes:
   - Change `lemma_2_7` Zorn seed from DC({xi}) to DC(B ∪ {xi}) → `xi ∈ B'`
   - Change `h_actual` counterexample check from f-values to g-values
   - Mirror changes for Since

2. **Task 3.8**: Close the 2 limit guard sorries using `adj_g_mem_limit_f` + base case from 3.7

3. **Tasks 4.3/4.4**: These should auto-resolve once 3.7/3.8 complete (the sorry sites at ChronicleConstruction.lean:1445,1457 ARE Tasks 4.3/4.4)

4. **Tasks 5.4-5.7**: Final validation (`#print axioms`, grep sorry, lake build)

**Estimate**: 4-8 hours

### Wave 2: Update Stale Documentation (CAN PARALLEL with Wave 1)

1. Update ROADMAP.md sorry counts and tables
2. Update Completeness.lean sorry documentation comments
3. Update plan v63 Task 3.7 status

**Estimate**: 1-2 hours

### Wave 3: Convention Migration (AFTER Wave 1)

Phase 6 of plan v63. Bottom-up swap:
1. Truth.lean semantics (2 lines)
2. Axioms.lean (35 sites)
3. Formula.lean derived ops
4. burgessR/burgessRSince definitions
5. All Chronicle code (~2141 refs)
6. Variable renaming
7. Comments/docs
8. Audit

**Estimate**: 8-16 hours (1-2 days)

### Wave 4: TemporalDerived Cleanup (AFTER Wave 1, PARALLEL with Wave 3)

1. Delete 17 unused sorry'd definitions
2. Handle `psi_imp_until`/`psi_imp_since` — either prove valid versions or remove callers
3. Mark `density_derivable` etc. as invalid with comments explaining why

**Estimate**: 2-4 hours

### Wave 5: Non-Critical Sorry Cleanup (DEFERRED, after all above)

1. 15 BXCanonical irreflexive-consequence sorries (task 109)
2. 3 RootScopedChain sorries (become dead code after Wave 1)
3. 6 Bundle sorries (low priority)

**Estimate**: 20-40 hours (task 109 scope)

### Wave 6: Full Project Cleanup (OPTIONAL)

1. Remove/archive 3 RootScopedChain sorries (dead code after Chronicle)
2. Boneyard audit
3. Task state cleanup (task 104)

---

## Effort Estimates

| Category | Effort | Priority | Blocks |
|----------|--------|----------|--------|
| Close 2 critical sorries (Wave 1) | 4-8h | **P0** | Completeness theorem |
| Documentation updates (Wave 2) | 1-2h | P1 | Nothing (but stale docs cause confusion) |
| Convention migration (Wave 3) | 8-16h | P1 | Readability, future development |
| TemporalDerived cleanup (Wave 4) | 2-4h | P2 | Clean axiom audit |
| BXCanonical sorry cleanup (Wave 5) | 20-40h | P3 | Nothing critical |
| Full project cleanup (Wave 6) | 4-8h | P4 | Nothing |
| **Total** | **39-78h** | | |

---

## Task Decomposition Proposal

### Keep as Task 107

- Wave 1 (close 2 critical sorries) — this IS task 107's core goal
- Wave 3 (convention migration) — already Phase 6 of plan v63

### Separate Tasks

| Proposed Task | Source | Rationale |
|---------------|--------|-----------|
| **ROADMAP.md update** | Wave 2 | Mechanical, can be done independently (task 106 exists but stale) |
| **TemporalDerived cleanup** | Wave 4 | Independent of completeness; could be new task or part of 105 |
| **BXCanonical sorry cleanup** | Wave 5 | Already covered by task 109 |
| **Task state cleanup** | Wave 6 | Already covered by task 104 |
| **Completeness.lean doc update** | Wave 2 | Could fold into task 105 (stale sorry-blocker comments) |

### Existing Tasks That Cover Remaining Work

| Existing Task | Status | Covers |
|---------------|--------|--------|
| 105 | NOT STARTED | Stale sorry-blocker comments in BXCanonical |
| 106 | IMPLEMENTING | ROADMAP.md rewrite (partially stale) |
| 109 | PLANNED | BXCanonical sorry closure (15+ sorries) |
| 104 | NOT STARTED | Task state cleanup |
| 95 | NOT STARTED | #print axioms audit (depends on 107) |
| 115 | RESEARCHED | Remove A4a + simplify BX2 (post-107 cleanup) |

---

## Strategic Recommendations

1. **Focus exclusively on Wave 1** for the next implementation cycle. The 2 remaining sorries are the ONLY thing blocking sorry-free `bx_completeness`. Everything else is cleanup.

2. **Convention migration (Wave 3) should be a separate branch** to isolate risk. It touches 33 files and ~2141 references. A merge conflict with any concurrent work would be painful.

3. **The ROADMAP is significantly stale** — it says 9 critical-path sorries exist when only 2 remain. This creates confusion for any agent reading it. A targeted update (just the numbers/tables) would take 30 minutes and prevent future agents from misunderstanding the state.

4. **TemporalDerived.lean is a latent risk**: 19 sorry stubs, 17 unused but 2 (`psi_imp_until`, `psi_imp_since`) are called from files on the critical import chain. While they don't contaminate `bx_completeness` axioms directly (the definitions calling them aren't used), they're dead weight that confuses sorry audits. Clean them up soon after Wave 1.

5. **Task 109 becomes mostly dead code cleanup** once task 107's Wave 1 succeeds. The 3 RootScopedChain sorries will no longer block anything. The 12 irreflexive-consequence sorries are independently valuable for code quality but not for completeness.

6. **The NoUnivBurgessR3 "6 stubs" in the ROADMAP are a phantom** — PointInsertion.lean has 0 sorry sites. The 7 references to `NoUnivBurgessR3` are the definition and type annotations, not sorry stubs. This ROADMAP entry should be removed.

7. **After completeness**: Consider writing a LaTeX paper. The proof infrastructure is mature and the mathematical contribution (first Lean 4 formalization of Burgess 1982 for bimodal TM logic) is significant.

---

## Confidence Level

**High** for the work inventory and sequencing.

The sorry inventory is exhaustive (based on `grep -c "sorry$"` across all active files). The critical-path analysis is verified by tracing imports and definition usage. The stale documentation findings are based on direct comparison of ROADMAP claims vs actual code state.

**Medium** for the effort estimates — the convention migration in particular could take longer than estimated if subtle semantic bugs surface during the audit phase.
