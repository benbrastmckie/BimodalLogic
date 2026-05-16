# Research Report: Task #154 - Systematic Solution for 17 Build Errors

**Task**: 154 - sum_preservation_ef_games
**Date**: 2026-05-16
**Mode**: Team Research (4 teammates)
**Session**: sess_1778923461_b0b07f

## Summary

All 4 teammates converge on a clear diagnosis: **5+ implementation attempts failed because every attempt used snippet-level verification (`lean_run_code`/`lean_multi_attempt`) rather than `lake build`, and every attempt tried incremental patching rather than complete block rewrites.** The 17 build errors divide into two clusters that CAN be fixed independently, but each cluster requires an atomic (complete-block) replacement, not line-by-line patches.

Two complementary Cluster 1 fixes were discovered and verified — one changes the type annotation (Teammate B: explicit `@Fin.cons` motive), one changes the proof term (Teammate A: tactic-mode `Fin.cases`). Both have HIGH confidence. For Cluster 2, all teammates agree on a k-split + complete cd0 rewrite, with MEDIUM confidence on the specific eM/eN implementation.

**Critical meta-finding (Teammate C)**: The only valid verification is `lake build`. All previous "verified" fixes were tested in isolation and failed when combined. The implementation plan MUST use `lake build` after each atomic change.

## Key Findings

### Cluster 1: build_bicompat h_idx' (6 errors, lines 548-550 and 629-631)

**Root cause**: `show (orderedSum sig I ms).carrier from ⟨j, c⟩` elaborates to `have this := ⟨j, c⟩; this`, an opaque let-binding. Lean's `Fin.cons` cannot infer the motive through this opacity, so `.1` (Sigma first-projection) fails.

**Fix Option A (Teammate A)** — Change proof term only:
```lean
-- Replace line 550 (and identically line 631):
-- OLD: Fin.cases rfl (fun k => h_idx k)
-- NEW:
fun p => by induction p using Fin.cases with | zero => rfl | succ k => rfl
```
Verified via `lean_multi_attempt` with zero diagnostics. Works because tactic-mode elaboration treats projections more uniformly — the `succ k` case produces `?m k.succ = ?m k.succ` where both sides have the same metavariable.

**Fix Option B (Teammate B)** — Change type annotation only:
```lean
-- Replace lines 547-549 (and identically 628-630):
-- OLD:
have h_idx' : ∀ p : Fin (n + 1),
    (Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M p).1 =
    (Fin.cons (show (orderedSum sig I ms').carrier from ⟨j, c'⟩) env_N p).1 :=
-- NEW:
have h_idx' : ∀ p : Fin (n + 1),
    (@Fin.cons n (fun _ => (orderedSum sig I ms).carrier) ⟨j, c⟩ env_M p).1 =
    (@Fin.cons n (fun _ => (orderedSum sig I ms').carrier) ⟨j, c'⟩ env_N p).1 :=
```
Proof term `Fin.cases rfl (fun k => h_idx k)` stays unchanged. Verified via `lean_run_code` end-to-end. Works because providing the explicit constant motive `(fun _ => T)` makes `.1` projection transparent. **Crucially, this form is definitionally equal to the `show T from` form** (confirmed via `rfl`), so `cd'` and the recursive `build_bicompat` call do NOT need changes.

**Recommendation**: Use Fix Option B (explicit motive). It's more principled (addresses root cause of motive inference) and has zero cascade risk due to definitional equality. If it fails in `lake build` due to the cd' type coupling that Teammate C identified, fall back to Fix Option A.

**Hidden risk (Teammate C)**: The `cd'` type annotation (lines 551-553) ALSO contains `show T from` patterns in its env arguments. Even after fixing `h_idx'`, these may cause latent errors to surface. The current 6 errors may become more once Cluster 1 is fixed. This is why `lake build` verification after Cluster 1 fix is essential before proceeding to Cluster 2.

### Cluster 2: sum_lift_one_var cd0 (11 errors, lines 788-812)

**Root cause**: Three interacting sub-issues:

1. **`bound` unprovable at k=0**: The field requires `1 < k + 1`. For `k = 0`, this is `1 < 1` — **FALSE**. No tactic can prove this. A case-split on `k` is mathematically necessary.

2. **`subst h` eliminates wrong variable**: With `h : j' = i`, `subst h` eliminates the outer parameter `i` (deeply embedded throughout the function) instead of the lambda-bound `j'`, destroying the proof context.

3. **Opaque eM/eN definitions**: `show Fin (if j' = i then 1 else 0) → (ms j').carrier from by rw ...` creates `Eq.mpr` wrappers that block `simp`, `convert`, and `funext`.

**Consensus fix (all teammates)**:
1. **Case-split on k at top level**: `k = 0` bypasses CompData entirely (return `sum_nf_lift_gen` with `h_bc := trivial`); `k = succ k'` proceeds with full cd0
2. **Replace `subst h` with `simp [h]` or `rw [if_pos h]`** in all fields
3. **Rewrite eM/eN as transparent definitions** — specific approach TBD after Cluster 1 resolution reveals true error set
4. **Write the entire cd0 block as a complete replacement**, not incremental patches (Teammate C's key recommendation)

**Confidence**: HIGH for the k-split structure, MEDIUM for the specific eM/eN and agree field implementation. The agree field's interaction with the eM/eN rewrite is the least understood part — needs concrete `lake build` verification.

### Strategic Assessment

**Patch vs. Restructure** (Teammates C + D):

| Factor | Patch | Restructure |
|--------|-------|-------------|
| Prior success rate | 0/5+ attempts | Not yet tried |
| Time already spent | ~20+ hours | 0 |
| Estimated additional time | 2-4 hours (if fixes work) | 4-6 hours |
| Success probability | MEDIUM (fixes verified in principle) | HIGH (eliminates root cause) |
| Downstream risk | Zero (all 24 defs are private) | Zero (same private scope) |

**Resolution**: Use a **staged escalation strategy**:
1. **Stage 1**: Apply Cluster 1 fix (4 lines, Option B explicit motive). Run `lake build`. ~5 min.
2. **Stage 2**: If Cluster 1 works, count remaining errors. Write complete cd0 replacement for Cluster 2. Run `lake build`. ~1 hour.
3. **Stage 3 (escalation)**: If Stages 1-2 fail or reveal >5 latent errors, restructure into separate file with decomposed lemmas per Teammate D's plan.

This gives the minimal fixes a fair shot while having a concrete fallback.

## Synthesis

### Conflicts Resolved

| Conflict | Resolution |
|----------|-----------|
| A changes proof term vs B changes type annotation for Cluster 1 | Both work. B is preferred (addresses root cause, zero cascade risk via defEq). A is backup. |
| C says clusters aren't truly independent vs A/B say they are | Technically coupled through `show T from` pattern, but B's defEq property means cd' doesn't need changes. After Cluster 1 fix, `lake build` reveals true Cluster 2 scope. Treat as conditionally independent. |
| C/D recommend restructure vs A/B recommend patch | Staged escalation: try patches first (they're cheaper), restructure if they fail. |
| Error count: handoffs say 15, current build shows 17 | Error masking: count changes as fixes reveal latent issues. Only trust current `lake build` output. |

### Gaps Identified

1. **cd' type coupling**: No teammate verified whether the `@Fin.cons` explicit motive approach propagates correctly through `cd'`'s type in the actual file context. Teammate B verified defEq in isolation; Teammate C warns the file context may differ.
2. **Latent errors after Cluster 1**: The true Cluster 2 error count is unknown until Cluster 1 is fixed. Current plan accounts for up to ~5 additional errors.
3. **agree field with transparent eM/eN**: The exact tactic sequence for the agree field after rewriting eM/eN has not been verified in file context. Multiple alternatives exist (`nf_agreement_monotone`, `cast`-based bridging, direct `simp`) but none tested with `lake build`.
4. **BiCompat definition (Teammate D)**: The `show T from x` pattern appears in BiCompat's DEFINITION (lines 166-180), not just proofs. If this is the true root, even perfect proof fixes may not suffice — but Teammate B's defEq argument suggests it's okay.

### Recommendations — Concrete Implementation Plan

**Phase 1: Fix Cluster 1 (lines 547-550, 628-631)**
- Apply Teammate B's `@Fin.cons` explicit motive to h_idx' type annotation at both sites
- Change only 4 lines (type annotations), keep proof terms unchanged
- **Verify with `lake build`** — NOT lean_run_code
- Expected result: 6 fewer errors, possible latent errors revealed

**Phase 2: Fix Cluster 2 (lines ~772-816)**
- Case-split `sum_lift_one_var` on `k` at the top level
- k=0: return `sum_nf_lift_gen sig 0 1 I ms ms' ... trivial sub_nf`
- k>0: complete rewrite of cd0 block with transparent eM/eN and `rw [if_pos h]`/`simp [h]` instead of `subst h`
- Write as a COMPLETE block replacement (not incremental patches)
- **Verify with `lake build`**

**Phase 3 (if needed): Restructure**
- Split `build_bicompat` into `build_bicompat_oracle_fwd`, `build_bicompat_oracle_bwd`, `build_bicompat_step`, `build_bicompat` wrapper
- Factor `sum_lift_one_var` + cd0 into separate lemma
- Optionally extract to SumPreservation.lean

**Verification protocol**: `lake build` is the ONLY valid verification. Do NOT use `lean_run_code` or `lean_multi_attempt` to "verify" fixes before applying them to the file.

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary: verified fix for Cluster 1 proof term + k-split for Cluster 2 | completed | high |
| B | Alternatives: explicit @Fin.cons motive fix (novel, addresses root cause) | completed | high |
| C | Critic: verification gap diagnosis, complete-rewrite recommendation | completed | high |
| D | Horizons: restructuring cost-benefit, dependency graph analysis | completed | medium-high |

## References

- Teammate A: `specs/154_sum_preservation_ef_games/reports/06_teammate-a-findings.md`
- Teammate B: `specs/154_sum_preservation_ef_games/reports/06_teammate-b-findings.md`
- Teammate C: `specs/154_sum_preservation_ef_games/reports/06_teammate-c-findings.md`
- Teammate D: `specs/154_sum_preservation_ef_games/reports/06_teammate-d-findings.md`
