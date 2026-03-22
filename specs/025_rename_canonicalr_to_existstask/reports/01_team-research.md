# Research Report: Task #25 - Shift to CanonicalTask/Succ Architecture

**Task**: 25 - rename_canonicalr_to_existstask
**Date**: 2026-03-22
**Mode**: Team Research (3 teammates)
**Focus**: Systematic audit and architecture design for CanonicalR → CanonicalTask/Succ shift

## Executive Summary

The codebase already has a clean separation between CanonicalR (existential accessibility) and CanonicalTask/Succ (step-indexed chains). **No file misuses CanonicalR where Succ or CanonicalTask would be more appropriate.** The rename CanonicalR → ExistsTask is a clean ~800-usage search-and-replace across 49 files. The real work is (1) proving per-witness strictness via fresh G-atoms to resolve the Task 29 inconsistency, and (2) retiring the 1200-line Gabbay infrastructure.

## Key Findings

### 1. The Separation Is Already Clean (Teammate A — HIGH confidence)

| Category | Files | Usages | Description |
|----------|-------|--------|-------------|
| Genuinely ExistsTask | 38 | ~680 | Existential accessibility in quotient ordering |
| Structural | 5 | ~90 | Frame properties of the accessibility relation |
| Definitional | 1 | 18 | Definition of CanonicalR itself |
| Comment-only | 5 | ~12 | Documentation references |
| Naturally Succ | **0** | **0** | No misuse as Succ |
| Naturally CanonicalTask | **0** | **0** | No misuse as CanonicalTask |

**The surprising result**: Every CanonicalR usage in the codebase is genuinely existential accessibility. No file confuses CanonicalR with Succ or CanonicalTask. The CanonicalTask/Succ infrastructure is already cleanly separate in its own files.

### 2. Two-Level Architecture Is Correct (Teammate B — HIGH confidence)

The codebase has two distinct levels:

| Level | Relation | Index | Used For |
|-------|----------|-------|----------|
| **ExistsTask** (= CanonicalR) | `g_content M ⊆ N` | None (binary) | Quotient ordering, frame properties, truth lemma wiring |
| **CanonicalTask/Succ** | Succ-chains of length n | ℤ (integer) | Step-indexed reasoning, bounded witnesses, F-step forcing |

**ExistsTask ≠ ∃ n ≥ 1, CanonicalTask** in general. ExistsTask only carries G-persistence; Succ additionally requires F-step. A single ExistsTask step does NOT imply a Succ step. The correct relationship:
- `Succ → ExistsTask` (proven: `Succ_implies_CanonicalR`)
- `ExistsTask → Succ` is NOT provable (F-step missing)
- `CanonicalTask_forward n → ExistsTask` (proven via chain of Succ → ExistsTask)

**The truth lemma does NOT directly mention CanonicalR.** It works through the abstract FMCS interface. No truth lemma changes are needed.

### 3. Per-Witness Strictness Replaces Universal Irreflexivity (Teammate C — HIGH confidence)

All 12 `canonicalR_strict` call sites share one pattern:
1. Seriality/density lemma gives witness W with `ExistsTask M W`
2. `canonicalR_strict` (from false axiom) gives `¬ExistsTask W M`
3. Together they close `[M] < [W]` in the quotient

**Fresh G-atom replacement**: For fresh atom p not in M, build seed `g_content(M) ∪ {G(p)}`, extend to MCS W. Then:
- `ExistsTask(M, W)`: g_content(M) ⊆ W (from seed) ✓
- `¬ExistsTask(W, M)`: G(p) ∈ W so p ∈ g_content(W), but p ∉ M (fresh) ✓

This gives ExistsTask (not Succ) — sufficient for the quotient ordering.

### 4. Gabbay Infrastructure Can Be Retired (Teammate C — HIGH confidence)

The 1200+ line `CanonicalIrreflexivity.lean` contains:
- `atomFreeSubset`, `namingSet`, `naming_set_consistent` — all for the Gabbay IRR proof
- Under reflexive semantics, the naming set `{p, H(¬p)}` is inconsistent (T-axiom gives ¬p from H(¬p))
- The entire infrastructure was valid only under strict semantics

**Replacement**: ~30 lines for the fresh G-atom lemma. The file reduces from 1254 to ~60 lines (just `canonicalR_reflexive` and `canonicalR_past_reflexive`).

### 5. ExistsTask(M, M) Is TRUE Under Reflexive Semantics (Teammate C)

- `ExistsTask(M, M)` = `g_content(M) ⊆ M` = TRUE (via T-axiom G(φ) → φ)
- This corresponds to `CanonicalTask(M, 0, M)` (zero-step identity)
- The quotient's strict ordering `[M] < [W]` requires `ExistsTask(M, W) ∧ ¬ExistsTask(W, M)`
- The reflexive case is harmless — it's built into the preorder

## Synthesis

### No Conflicts Between Teammates

All three teammates converge on the same picture:
- The rename is clean and mechanical
- The architectural separation already exists
- The Task 29 blocker resolves via fresh G-atoms at the ExistsTask level

### What "Shift Focus to CanonicalTask" Actually Means

The user's intent to "shift focus to CanonicalTask" is better understood as:

1. **Rename**: CanonicalR → ExistsTask (makes it clear this is a derived/existential notion)
2. **Minimize ExistsTask reasoning**: Where proofs reason about ExistsTask, check if they could reason about Succ/CanonicalTask instead — but the audit shows this is rare; ExistsTask is genuinely the right abstraction for ordering
3. **New theorems in CanonicalTask terms**: `CanonicalTask_no_positive_cycle`, `Succ_step_changes_content` — these capture the "Succ makes progress" property that replaces universal irreflexivity
4. **Retire Gabbay**: Remove the 1200-line infrastructure that served the old strict-semantics irreflexivity proof

### Two Parallel Workstreams

| Workstream | Files | Effort | Dependency |
|------------|-------|--------|------------|
| **A: Rename** CanonicalR → ExistsTask | 49 files, ~800 usages | 3-4h (mostly search-replace) | None |
| **B: Resolve inconsistency** (Task 29 Phase 5) | ~6 files | 6-8h (fresh G-atom + call sites) | None |

These can be done in either order or in parallel. The rename is mechanical; the inconsistency resolution is mathematical.

### Edge Cases for Rename (5 sites requiring manual review)

1. `rw [CanonicalR, Set.not_subset]` in SeparationLemma.lean — needs `@[simp] lemma ExistsTask_def`
2. `rw [CanonicalR, ...]` in ConstructiveFragment.lean — same
3. `CanonicalR_chain` → `ExistsTask_chain` (distinct from CanonicalTask!)
4. `CanonicalR_past` → `ExistsTask_past`
5. `CanonicalR_reachable` → `ExistsTask_reachable`

## Recommended Implementation Plan

### Phase 1: Fresh G-Atom Infrastructure (2-3h)
- Prove `fresh_atom_Gp_seed_consistent`
- Prove `existsTask_strict_fresh_atom` (∃ W, ExistsTask M W ∧ ¬ExistsTask W M)
- This resolves the Task 29 inconsistency

### Phase 2: Update Call Sites (3-4h)
- Replace 12 `canonicalR_strict` call sites with fresh G-atom
- Handle `inl h_eq` cases in CanonicalSerialFrameInstance
- Delete `canonicalR_irreflexive_axiom`

### Phase 3: Retire Gabbay Infrastructure (1h)
- Remove `atomFreeSubset`, `namingSet`, `naming_set_consistent`, etc.
- Keep `canonicalR_reflexive`, `canonicalR_past_reflexive`
- Reduce CanonicalIrreflexivity.lean from 1254 to ~60 lines

### Phase 4: Rename CanonicalR → ExistsTask (3-4h)
- Rename definition in CanonicalFrame.lean
- Batch search-replace across all 49 files
- Manual review of 5 edge cases
- Update Boneyard files

### Phase 5: New CanonicalTask Theorems (2-3h, optional)
- `CanonicalTask_no_positive_cycle`: no positive-length Succ-chain loops
- `Succ_step_changes_content`: Succ-steps make progress
- These strengthen the theoretical foundation but aren't blocking

**Total: 12-16 hours** (Phases 1-4 are essential; Phase 5 is optional enrichment)

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Finding |
|----------|-------|--------|------------|-------------|
| A | File-by-file audit | completed | high | 0 files misuse CanonicalR; rename is clean search-replace |
| B | Architecture design | completed | high | Two-level architecture correct; ExistsTask ≠ ∃ CanonicalTask |
| C | Irreflexivity resolution | completed | high | 12 call sites, all same pattern; Gabbay retirable |

## References

- `specs/025_rename_canonicalr_to_existstask/reports/01_teammate-a-findings.md` — Full audit
- `specs/025_rename_canonicalr_to_existstask/reports/01_teammate-b-findings.md` — Architecture
- `specs/025_rename_canonicalr_to_existstask/reports/01_teammate-c-findings.md` — Irreflexivity
- `Theories/Bimodal/Metalogic/Bundle/CanonicalFrame.lean` — CanonicalR definition
- `Theories/Bimodal/Metalogic/Bundle/CanonicalTaskRelation.lean` — CanonicalTask definition
- `Theories/Bimodal/Metalogic/Bundle/SuccRelation.lean` — Succ definition
