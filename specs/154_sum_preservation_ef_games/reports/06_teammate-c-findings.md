# Teammate C (Critic) Findings: Why 5+ Attempts Failed

**Task**: 154 - sum_preservation_ef_games
**Date**: 2026-05-16
**Angle**: Root cause analysis of repeated implementation failures

## Key Findings

### Finding 1: The Verification Gap — "Works in Isolation" Is Not Verification

**Confidence: HIGH**

Every handoff claims fixes were "verified via `lean_run_code`" or "`lean_multi_attempt`." These tools test *snippets in isolation* — they do NOT compile the snippet within the actual file context. This is the single most important failure pattern:

- `lean_run_code` creates a standalone environment. It doesn't see `orderedSum` being `noncomputable def`, doesn't see the actual `CompData` structure parameterized over real `env_M`/`env_N`, and doesn't reproduce the elaboration context where `show T from e` is opaque.
- `lean_multi_attempt` tests tactics at a specific proof position but cannot verify that a change at line 548 doesn't cascade to line 558 (the `cd'` construction that depends on `h_idx'`).
- The v7 implementation handoff explicitly states: "each fix pattern works in isolation but combining them triggers cascading elaboration issues." This means **not a single fix was actually verified in the real file context**.

**Why this matters**: Agents spend hours "verifying" fixes that don't actually work when applied. A `lake build` after each atomic edit would reveal this immediately, but the ~3-minute build time discourages it.

### Finding 2: The "Two Independent Clusters" Framing Is Wrong

**Confidence: HIGH**

Previous research (05_team-research.md) claims "exactly 2 independent root causes." This is **misleading** — the two clusters share a deep dependency through the `show T from` pattern:

1. **Cluster 1** (lines 547-550, 628-631): `h_idx'` and `cd'` use `show (orderedSum sig I ms).carrier from ⟨j, c⟩` — this is opaque to `.1` projection.
2. **Cluster 2** (lines 772-812): `cd0` uses `show Fin (if j' = i then 1 else 0) → (ms j').carrier from by rw ...` — this is opaque to `dif_pos rfl` reduction.

These are the **same underlying pattern**: `show T from e` elaborates to `have this := e; this`, creating an opaque let-binding. The fix principle is identical — avoid `show T from e` everywhere. The fact that previous research treats them as "independent" causes agents to attempt partial fixes, which cascade.

Furthermore, Cluster 1 has a **hidden third sub-cluster**: even after fixing `h_idx'`, the `cd'` type annotation on lines 551-553 ALSO contains `show ... from` patterns. No handoff clearly distinguishes that `cd'`'s TYPE (not just `h_idx'`'s definition) uses opaque patterns. The cd' type governs how Lean elaborates ALL its fields — if the type contains opaque terms, field elaboration may silently fail even with "correct" field definitions.

### Finding 3: CompData Type Parameterization Is the Hidden Coupling

**Confidence: HIGH**

The `CompData` structure (line 297) is parameterized by `env_M`, `env_N`, and `h_idx`. This means:

```lean
CompData sig I ms ms' budget
    (Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M)
    (Fin.cons (show (orderedSum sig I ms').carrier from ⟨j, c'⟩) env_N)
    h_idx'
```

The opaque `show ... from` terms appear IN THE TYPE of `cd'`, not just in `h_idx'`. When you fix `h_idx'` to use `let envM_ext`, you ALSO need `cd'`'s type to reference `envM_ext`/`envN_ext`, AND the recursive `build_bicompat` call at line 588 must also use these. This is a THREE-SITE coordinated change, not a one-site fix.

The v7 implementation handoff documents this under "Approaches Tried and Failed": "`let envM_ext` bindings — Changes CompData parameterization, breaks eM/eN/consistent field types." This means the obvious fix was tried and FAILED, but no research has adequately explained WHY it failed or found a workaround.

### Finding 4: The `subst` Problem in cd0 Is More Than "Wrong Variable"

**Confidence: MEDIUM**

In `sum_lift_one_var` (line 786), `subst h` with `h : j' = i` eliminates `i` (the outer parameter) because Lean's `subst` prefers to eliminate free variables over lambda-bound ones when both are available. Previous research says "use `simp [h]` or `rw [h]` instead."

But this overlooks that `i` appears throughout the ENTIRE `sum_lift_one_var` function — in `a : (ms i).carrier`, `b : (ms' i).carrier`, `h_agree_comp`, `envM`, `envN`, etc. After `subst h` eliminates `i` and replaces it with `j'`, ALL of these references change type. The reason `subst` is so destructive here isn't just "wrong variable" — it's that `i` is a deeply-embedded parameter.

The proposed alternatives (`simp [h]`, `rw [h]`) avoid this, but they produce DIFFERENT goal states than what the rest of the proof expects. Nobody has documented what the goal state actually looks like after `rw [h]` vs `subst h` in this context.

### Finding 5: Error Count Keeps Changing — Indicating Masking

**Confidence: HIGH**

The error count has drifted across handoffs:
- Phase 2-3 handoff (v7): 16 errors
- Phase 2 handoff (v8): 17 errors → fixed 2, left 15
- Team research (05): 15 errors (after v8 fix)
- Implementation v7: claims 15 but describes ~20 including "latent" ones
- Current `lake build`: 17 errors

This is not mere accounting — it reflects **error masking**. Early errors prevent Lean from elaborating subsequent code, hiding additional errors. When you fix the first 6 errors (Cluster 1), you EXPOSE errors that weren't previously visible. The v7 handoff explicitly warns about "Category 1b: cd' eM/eN fields (latent, exposed after h_idx' fix)."

This means the plan that says "fix 15 errors" is fundamentally undercounting. The true number of errors is unknown until Cluster 1 is fully fixed and `lake build` reveals what was hidden.

### Finding 6: The k=0 Case Split May Not Interact Cleanly

**Confidence: MEDIUM**

For `sum_lift_one_var`, the proposed case-split on `k` for the `bound` field unprovability at `k = 0` is correct in principle. But nobody has verified:

1. Whether `BiCompat sig 0 1` actually reduces to `True` in this context (it should by definition, but `orderedSum` opacity could prevent reduction)
2. Whether `sum_nf_lift_gen sig 0 1 I ms ms' ... trivial sub_nf` type-checks when `sub_nf : NormalForm sig 0 (0 + 1)` (the types need `k = 0` to be visible)
3. Whether the caller `sum_nf_agree_sentence` at the induction step passes `k` vs `k+1` (need to check if `k=0` case is even reachable)

### Finding 7: No Agent Has Attempted a Clean Rewrite

**Confidence: HIGH**

Every attempt has tried to PATCH the existing code — fixing individual fields, replacing specific patterns. This patch-based approach explains the repeated failures: each patch creates a slightly different elaboration context that causes the next patch to fail.

An alternative never tried: **rewrite `build_bicompat`'s forward/backward oracle sections from scratch** using a consistent pattern. Instead of changing `show T from e` to `let x := e` in one place and hoping cd' still elaborates, write the entire section — from `oracle_step` through `cd'` through the recursive call — in a single coherent block that never uses `show T from e` anywhere.

Similarly for `sum_lift_one_var`: instead of patching `eM`, then `agree`, then `bound` independently, rewrite the entire `cd0` construction from scratch with the case-split on `k` and transparent definitions throughout.

## Recommended Approach (Research Direction)

1. **Stop verifying with `lean_run_code`/`lean_multi_attempt`**. The only valid verification for these fixes is `lake build`. Accept the 3-minute cost per iteration.

2. **Treat both clusters as ONE problem**: eliminate ALL instances of `show T from e` in the file simultaneously. Don't fix Cluster 1 and then Cluster 2 — fix the pattern everywhere at once.

3. **Rewrite, don't patch**: For each of the two main code blocks (`build_bicompat` oracle sections, `sum_lift_one_var` cd0), write the replacement code as a complete block rather than editing individual lines. This eliminates the cascading issue where fixing one field breaks the elaboration context for the next.

4. **Understand what `let envM_ext` actually broke**: The v7 handoff says it "changes CompData parameterization, breaks eM/eN/consistent field types." This needs to be diagnosed precisely — does it change the TYPE of `cd'` in a way that makes fields ill-typed, or does it just change the elaboration hints? This is the single most important technical question that hasn't been answered.

5. **Profile the true error count**: After fixing ONLY the 6 Cluster 1 errors (via a complete rewrite of lines 547-588 and 628-669), run `lake build` to reveal the latent errors. Only then design the remaining fixes.

6. **Consider factoring `sum_lift_one_var` out of the file**: At 1133 lines, the file is at the limit of Lean's elaboration tolerance. If `sum_lift_one_var` were in its own file importing `build_bicompat`, the elaboration context would be simpler and errors would be more isolated.

## Evidence/Examples

### Evidence for Finding 1 (Verification Gap)

From implementation-v7-handoff-20260516.md:
> "5 agents spawned across 2 waves. All 15 build errors stem from the same root cause... but fixing them requires coordinated ~80-line changes across two functions with cascading tactic interactions."

And:
> "Each fix pattern works in isolation but combining them triggers cascading elaboration issues"

This is the textbook symptom of testing snippets outside their elaboration context.

### Evidence for Finding 3 (cd' Type Coupling)

Current code (lines 551-554):
```lean
have cd' : CompData sig I ms ms' budget
    (Fin.cons (show (orderedSum sig I ms).carrier from ⟨j, c⟩) env_M)
    (Fin.cons (show (orderedSum sig I ms').carrier from ⟨j, c'⟩) env_N)
    h_idx' := {
```

The TYPE of cd' contains THREE `show T from e` patterns (two in env arguments, one via `h_idx'`). Even if `h_idx'` is fixed, the env arguments still use opaque patterns. These opaque terms propagate into the expected types of ALL cd' fields (`sz`, `eM`, `eN`, `agree`, `bound`, `consistent`).

### Evidence for Finding 5 (Error Masking)

From implementation-v7-handoff-20260516.md:
> "eM/eN fields in build_bicompat expose LATENT type mismatches once h_idx' is fixed (these weren't visible before because h_idx' failure masked them)"

This confirms error masking is a known phenomenon in this codebase but the plans don't account for it.

## Confidence Level

**Overall: HIGH** for the diagnosis, **MEDIUM** for specific fix approaches (since no fix has been tested in the real context).

The central thesis — that snippet-level verification is misleading and the "two independent clusters" framing prevents holistic fixes — is strongly supported by the evidence across all 9 handoffs. The repeated pattern of "verified fix fails when applied" is pathognomonic for the verification gap identified in Finding 1.
