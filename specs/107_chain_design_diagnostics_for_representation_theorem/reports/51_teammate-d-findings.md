# Teammate D (Horizons): Strategic Analysis for Task 107

**Date**: 2026-05-01
**Focus**: Cruft identification, sorry census, ROADMAP alignment, streamlined plan proposal

## Key Findings

1. **ROADMAP sorry count is stale**: Claims "4 sorry sites" in Chronicle and "PointInsertion.lean is sorry-free", but PointInsertion has 3 actual sorry sites (dead code per report 50). True Chronicle count is 7 sorries across 3 files, of which **only 4 are on the critical path**.

2. **Completeness.lean comments are very stale**: Claims "11 sorry sites on critical path" but reality is 4 critical-path + 3 dead-code sorries.

3. **The entire BXCanonical path (non-Chronicle) is dead code for completeness**: `bx_completeness` now calls `dd_countermodel_chronicle`, not `dd_countermodel`. The 15 non-Chronicle BXCanonical sorries (RootScopedChain 3, Quasimodel 6, Frame 1, TruthLemma 2, SigmaOrdering 3) are **not on the critical path to completeness**.

4. **50 reports for 4 blocking sorries is extreme churn**: Process itself contributed. Many reports identified "breakthroughs" that turned out false (C4 swap, density axioms, g_content_sub_B paths). A "try it first, research if stuck" approach would be more effective.

5. **The 3 PointInsertion sorries should be deleted, not archived**: They are private functions with zero external callers, called only by `splitting_seed_consistent` and `lemma_2_6_splitting`/`lemma_2_7` which themselves have zero external callers. Deleting them reduces cognitive load.

## Sorry Census: All BXCanonical (22 total)

### Chronicle/ (7 sorries, 4 on critical path)

| # | File | Line | Function | On Critical Path? | Dead Code? | Difficulty |
|---|------|------|----------|-------------------|------------|------------|
| 1 | PointInsertion.lean | 857 | `g_content_sub_B` (inconsistent case) | **No** | Yes — called only by `splitting_seed_consistent` which has 0 callers | N/A (delete) |
| 2 | PointInsertion.lean | 879 | `h_content_sub_B` (inconsistent case) | **No** | Yes — dual of above | N/A (delete) |
| 3 | PointInsertion.lean | 1052 | `lemma_2_7` | **No** | Yes — zero callers anywhere | N/A (delete) |
| 4 | CounterexampleElimination.lean | 412 | `eliminate_C4_counterexample` (hard case) | **Yes** | No — called at line 817 | Hard |
| 5 | CounterexampleElimination.lean | 510 | `eliminate_C4'_counterexample` (hard case) | **Yes** | No — mirror of #4 | Hard (same as #4) |
| 6 | ChronicleToCountermodel.lean | 615 | `cantor_bfmcs_restricted_fuc` (FUC) | **Yes** | No — called at line 663 | Medium |
| 7 | ChronicleToCountermodel.lean | 619 | `cantor_bfmcs_restricted_fuc` (FSC) | **Yes** | No — mirror of #6 | Medium (same as #6) |

### Non-Chronicle BXCanonical (15 sorries, 0 on critical path)

| # | File | Line | Function | Dead Code? | Note |
|---|------|------|----------|------------|------|
| 8 | Frame.lean | 205 | `bx_le_refl` | Structurally dead (irreflexive semantics) | Intentionally invalid |
| 9 | TruthLemma.lean | 296 | `until_backward_refl_mcs` | Dead (irreflexive) | BX1 removed |
| 10 | TruthLemma.lean | 321 | `since_backward_refl_mcs` | Dead (irreflexive) | BX1 removed |
| 11 | Quasimodel/Construction.lean | 150 | `refl_intro_until_mcs` | Dead (irreflexive) | BX1 removed |
| 12 | Quasimodel/Construction.lean | 186 | `refl_intro_since_mcs` | Dead (irreflexive) | BX1 removed |
| 13 | Quasimodel/Realization.lean | 67 | `F_of_mem` | Dead (irreflexive) | BX1 removed |
| 14 | Quasimodel/Realization.lean | 73 | `P_of_mem` | Dead (irreflexive) | BX1 removed |
| 15 | Quasimodel/Realization.lean | 197 | g_content in seed | Dead (irreflexive) | BX1 removed |
| 16 | Quasimodel/Realization.lean | 249 | h_content in seed | Dead (irreflexive) | BX1 removed |
| 17 | Filtration/SigmaOrdering.lean | 82 | `sigma_le_refl` | Dead (irreflexive) | BX1 removed |
| 18 | Filtration/SigmaOrdering.lean | 99 | `sigma_strict_irrefl` | Dead (irreflexive) | BX1 removed |
| 19 | Filtration/SigmaOrdering.lean | 143 | `not_sigma_equiv` | Dead (irreflexive) | BX1 removed |
| 20 | RootScopedChain.lean | 186 | `bx_bfmcs_restricted_tc` | Dead for completeness | `dd_countermodel` bypassed |
| 21 | RootScopedChain.lean | 193 | `bx_bfmcs_restricted_buc` | Dead for completeness | `dd_countermodel` bypassed |
| 22 | RootScopedChain.lean | 198 | `bx_bfmcs_restricted_fuc` | Dead for completeness | `dd_countermodel` bypassed |

## Cruft Audit

### Delete (not archive — these are private functions with zero callers)

In `PointInsertion.lean`:
- Lines 839-857: `g_content_sub_B` (private, only caller is `splitting_seed_consistent` which has 0 external callers)
- Lines 861-879: `h_content_sub_B` (private, dual)
- Lines 889-906: `splitting_seed_consistent` (private, only caller is `lemma_2_6_splitting` which has 0 external callers)
- Lines 908-933: `lemma_2_6_splitting` (public, zero callers)
- Lines 935-1052: `lemma_2_7` and its helpers (zero callers): `right_mono_until_mcs`, `untl_conj_eta_of_g_content`
- Lines 800-824: `G_conj_strengthen`, `H_conj_strengthen` (only called by dead g/h_content_sub_B)

**Total**: ~280 lines of dead code in PointInsertion.lean. Note that lines 771-776 already document the first wave of archival (to Boneyard/NonBurgessSeed/). This second wave should either extend that archive or just delete outright since the archived version already captures the approach.

### Consider for Boneyard (but not blocking)

- **RootScopedChain.lean**: 3 sorry sites, bypassed by `dd_countermodel_chronicle`. However, it's still imported by `Completeness.lean` and `dd_countermodel` is still defined. Not urgent to archive — the file serves as documentation of the BXCanonical path attempt.

### Update stale comments

- **Completeness.lean lines 187-198**: Claims "11 sorry sites on critical path" — actually 4 critical-path + 3 dead-code
- **ROADMAP.md lines 50-57**: Claims 4 chronicle sorries — actually 7 (3 dead + 4 active)
- **ROADMAP.md line 26**: Claims "PointInsertion.lean is sorry-free" — has 3 sorries (dead code)
- **ROADMAP.md lines 282-286**: Stale "Current state" paragraph

## Streamlined Plan Proposal

### Phase 0: Clean Slate (1 hour)
- Delete dead code from PointInsertion.lean (~280 lines): g_content_sub_B, h_content_sub_B, splitting_seed_consistent, lemma_2_6_splitting, lemma_2_7, and all private helpers
- Update stale comments in Completeness.lean
- Update ROADMAP.md sorry counts
- `lake build` to verify no breakage
- Commit

### Phase 1: C4/C4' Hard Case (4-6 hours)
**Sorries 4-5**: `eliminate_C4_counterexample` and `eliminate_C4'_counterexample`

The hard case needs: given adjacent (w, w_next), construct BurgessR3Maximal(f(w), g(w,w_next), f(w_next)), then apply Lemma 2.6 splitting to find D with γ.neg ∈ D.

Key question (from report 50): Is `g_content(f(w)) ⊆ f(w_next)` maintained? If yes, `burgessR3Maximal_from_g_content_sub` provides c2'. This is the **critical research question** — answer it with `lean_goal` at line 412, not with another team research report.

Approach:
1. Use `lean_goal` at the sorry site to see the exact proof state
2. Check what hypothesis is available about g(w, w_next) and f(w), f(w_next)
3. If g_content(f(w)) ⊆ f(w_next) is available: use `burgessR3Maximal_from_g_content_sub` then Lemma 2.6 logic inline
4. If not: need to trace how the omega_chain provides g-values for adjacent pairs

Since C4' is a mirror, solving C4 gives C4' immediately.

### Phase 2: FUC/FSC Coherence (3-5 hours)
**Sorries 6-7**: `cantor_bfmcs_restricted_fuc`

The proof needs: for U(φ,ψ) ∈ f(t), find s > t with ψ ∈ f(s) and φ ∈ f(r) for all r between t and s.

Available infrastructure:
- `limit_satisfies_c5_weak`: gives ∃ y > t, ψ ∈ limit_f(y) — the **endpoint**
- `limit_g(x,z) = {φ | ∀ y ∈ dom, x < y → y < z → φ ∈ limit_f(y)}` — the **guard set**
- `limit_c3_interval_subset_point`: limit_g(x,z) ⊆ limit_f(y) for x < y < z

The key insight (from report 50, Resolution path 3): If C5 gives witness y and C3 gives g(t,y) ⊆ f(r) for t < r < y, then the guard condition follows if φ ∈ limit_g(t,y). Need to show that the C5 witness includes φ in the limit_g interval.

This may require strengthening the C5 elimination or proving that limit_g(t,y) contains the guard formula φ when U(φ,ψ) ∈ limit_f(t).

Approach: check if C5_weak's witness y already satisfies η ∈ limit_g(t,y) (which would mean the guard is automatic from limit_g's definition). If not, need the stronger C5 that includes guard info.

### Phase 3: ROADMAP Update + Final Audit (0.5 hours)
- Update ROADMAP.md sorry counts to 0
- Update Completeness.lean comments
- `#print axioms dd_countermodel_chronicle` audit
- Commit

**Total: 3 phases, ~8-12 hours, targeting exactly the 4 critical-path sorries.**

## ROADMAP Alignment Analysis

### Current ROADMAP State
- Chronicle is correctly identified as PRIMARY completeness path (Section "Active Metalogic Paths")
- BXCanonical correctly identified as SECONDARY (blocked by Lindenbaum opacity)
- "Representation Theorem Goal" section correctly states D=Rat over totally ordered abelian groups
- Priority order correct: Task 107 is #1

### What Completing Task 107 Unblocks
- **Task 95**: `#print axioms` audit (depends on 107 or 109)
- **Task 109**: BXCanonical sorries become lower priority (all dead code for completeness once chronicle is sorry-free)
- **Task 115**: A4a removal (post-107 cleanup)
- **Publication**: A sorry-free `bx_completeness` is the primary milestone

### Minimal Viable Outcome
Close the 4 critical-path sorries in Chronicle/. This achieves:
- sorry-free `dd_countermodel_chronicle`
- sorry-free `bx_completeness` (modulo non-Chronicle BXCanonical sorries which are off the critical path)
- The representation theorem milestone

### ROADMAP Updates Needed
1. Update chronicle sorry count: 7 → 4 active (after Phase 0 cleanup reduces to 4 by deleting dead code)
2. Correct PointInsertion.lean status: remove "sorry-free" claim
3. Update "Current state" paragraph
4. Note A7a axiom status (added alongside BX7, not replacing it)

## Process Improvement Observations

### The Churn Problem
50 research reports and 49 plans for a task with 4 blocking sorries is pathological. Contributing factors:
1. **Research before implementation**: Reports often theorize about what Lean proofs need without checking. `lean_goal` at each sorry site would immediately reveal the proof obligation.
2. **Plan-heavy workflow**: Plans describe proof strategies in prose, but the actual blockers are Lean type-checking constraints that are only visible in the proof state.
3. **False breakthroughs**: Reports 25, 40, 41, 47 each announced "breakthroughs" that required subsequent correction.
4. **Architectural churn**: Repeated addition/removal of c2' from omega_chain, A7a addition/removal, D0 seed attempts — multiple attempts at the same problem with slightly different framing.

### Recommended Process Change
For the remaining 4 sorries:
1. **Start with `lean_goal`** at each sorry site to see the exact proof state
2. **Try `lean_multi_attempt`** with obvious tactics (simp, exact, apply)
3. **Only research if stuck** after understanding the precise Lean obligation
4. **No more team research** — the mathematics is well-understood from Burgess 1982. The blockers are Lean formalization gaps, not conceptual gaps.

## Confidence Level

- **Sorry census**: **High** — based on mechanical grep of all `sorry` in BXCanonical/
- **Dead code identification**: **High** — based on grep for callers of each function
- **Streamlined plan**: **Medium** — the C4 and FUC/FSC approaches need verification via lean_goal
- **Process improvement**: **High** — the evidence of churn is in the 50 reports themselves
- **ROADMAP alignment**: **High** — based on direct reading of ROADMAP.md

## References

- Report 50: `specs/107_chain_design_diagnostics_for_representation_theorem/reports/50_sorry-architecture-audit.md`
- Plan v35: `specs/107_chain_design_diagnostics_for_representation_theorem/plans/49_implementation-plan.md`
- ROADMAP: `specs/ROADMAP.md`
- Burgess 1982: `literature/Burgess_1982_Axioms_for_tense_logic_Since_and_Until.md`
