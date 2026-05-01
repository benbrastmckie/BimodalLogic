# Report: Sorry Architecture Audit — Plan v35 Misalignment

- **Task**: 107 - Burgess chronicle construction for BX representation theorem
- **Type**: Architecture audit
- **Date**: 2026-05-01
- **Trigger**: Three Phase 3 agents failed to implement Burgess D0 seed; investigation revealed plan-codebase misalignment

## Executive Summary

Plan v35 assumes a dependency chain: fix SoundnessLemmas → restructure Lemma 2.6 seed → archive dead code → rewrite Lemma 2.7 → close C4/C4' → close FUC/FSC. Investigation reveals that **Lemma 2.6 and 2.7 have zero callers** — they are disconnected infrastructure that does not feed into any sorry site. The 4 sorry sites that actually block `dd_countermodel_chronicle` have different blockers than the plan addresses. The plan needs revision.

## Sorry Inventory

Seven sorry sites across 3 files in `Theories/Bimodal/Metalogic/BXCanonical/Chronicle/`:

| # | File | Line | What | Callers | Blocks dd_countermodel? |
|---|------|------|------|---------|------------------------|
| 1 | PointInsertion.lean | 857 | `g_content_sub_B` (density gap, inconsistent case) | **None** | No |
| 2 | PointInsertion.lean | 879 | `h_content_sub_B` (density gap, dual) | **None** | No |
| 3 | PointInsertion.lean | 1052 | `lemma_2_7` (Until-formula splitting stub) | **None** | No |
| 4 | CounterexampleElimination.lean | 412 | C4 hard case (γ ∈ f(x) ∧ γ ∈ f(y)) | `eliminate_C4_counterexample` | **Yes** |
| 5 | CounterexampleElimination.lean | 510 | C4' hard case (Since direction mirror) | `eliminate_C4'_counterexample` | **Yes** |
| 6 | ChronicleToCountermodel.lean | 615 | FUC (forward Until coherence) | `cantor_bfmcs_restricted_fuc` | **Yes** |
| 7 | ChronicleToCountermodel.lean | 619 | FSC (forward Since coherence) | `cantor_bfmcs_restricted_fuc` | **Yes** |

### Key Finding: Sorries 1-3 Are Dead Code

`lemma_2_6_splitting` (lines 908-934) and `lemma_2_7` (line 1032) are defined but **never referenced** anywhere in the codebase:

```bash
$ grep -rn "lemma_2_6_splitting\|lemma_2_7" Theories/ --include="*.lean"
# Returns ONLY definitions and comments — zero usage sites
```

The functions `g_content_sub_B` and `h_content_sub_B` are called only by `splitting_seed_consistent`, which is called only by `lemma_2_6_splitting` — which has no callers. The entire chain is orphaned.

**Implication**: Closing sorries 1-3 has zero effect on `dd_countermodel_chronicle`. They can be archived to Boneyard.

## Actual Blockers for dd_countermodel_chronicle

### Blocker A: C4/C4' Hard Case (Sorries 4-5)

**Location**: `eliminate_C4_counterexample` and `eliminate_C4'_counterexample`

**Proof obligation**: Given a C4 counterexample where `neg(U(γ, δ)) ∈ f(x)` and `δ ∈ f(y)` with `x < y`, find `z` between `x` and `y` with `γ.neg ∈ f(z)`.

**Easy cases** (already proved):
- `γ.neg ∈ f(x)`: take z with f(z) = f(x)
- `γ.neg ∈ f(y)`: take z with f(z) = f(y)

**Hard case** (sorry): `γ ∈ f(x)` AND `γ ∈ f(y)`. The proof strategy is:
1. Find the rightmost domain point `w` with `neg(U(γ, δ)) ∈ f(w)` before `y`
2. Find `w_next`, the successor of `w` in the domain (adjacent pair)
3. Use `BurgessR3Maximal(f(w), g(w, w_next), f(w_next))` — this is `c2'`
4. Apply a splitting/bridging lemma to find MCS D with `γ.neg ∈ D`

**The actual blocker**: Step 3 requires `c2'` (BurgessR3Maximal for adjacent pairs), but `c2'` is NOT available at finite stages. The omega_chain only carries `c0` (MCS at domain points). The comment at line 246 of ChronicleConstruction.lean states:

> "The c2' invariant is no longer threaded through finite stages (Phase 7 change); it is vacuously true at the limit since the limit domain is dense with no adjacent pairs."

But the C4 elimination operates AT finite stages (before taking the limit), where adjacent pairs DO exist and c2' IS needed.

**Architecture gap**: c2' was removed from the omega_chain invariant in a prior phase. It needs to be either:
- Re-added to the omega_chain invariant (each step maintains BurgessR3Maximal for adjacent pairs), or
- The C4 elimination needs an alternative approach that doesn't rely on c2'

**What c2' requires**: For each adjacent pair (w, w_next) after a point insertion, establish `BurgessR3Maximal(f(w), g(w, w_next), f(w_next))`. This needs:
- `burgessR3(f(w), g(w, w_next), f(w_next))` — i.e., the g-value satisfies the R3 relation
- Maximality via Zorn (`burgessR3Maximal_extension_exists`)
- The g-value must be initially seeded with at least one element η where `burgessR(f(w), η, f(w_next))` and `burgessRSince(f(w_next), η, f(w))` and `η ∈ f(w)`

**Simplest path**: Use `burgessR3Maximal_from_g_content_sub` which establishes BurgessR3Maximal from `g_content(A) ⊆ C`. Since the chronicle maintains `g_content(f(w)) ⊆ f(w_next)` for adjacent pairs (part of the G-propagation invariant), this may already be available. **The g_content_sub_B sorry is NOT needed here** — that's about g_content(A) ⊆ B (the middle set), not about g_content(A) ⊆ C (which is separately established).

### Blocker B: FUC/FSC Coherence (Sorries 6-7)

**Location**: `cantor_bfmcs_restricted_fuc`

**Proof obligation**: For `U(φ, ψ) ∈ f(t)`, find `s > t` with `ψ ∈ f(s)` AND `φ ∈ f(r)` for all `r` with `t < r < s` (the guard condition).

**What's available**:
- `limit_satisfies_c5_weak`: gives `∃ y > t, ψ ∈ f(y)` — the endpoint exists
- `limit_g`: defined as `{φ | ∀ y ∈ dom, x < y → y < z → φ ∈ f(y)}` — automatically satisfies C3
- `limit_g_c3`: `limit_g(x,z) = limit_g(x,y) ∩ limit_f(y) ∩ limit_g(y,z)` (sorry-free)
- `limit_g_subset_f`: `limit_g(x,z) ⊆ limit_f(y)` for `x < y < z` (sorry-free)

**The actual blocker**: The C5 elimination step (at finite stages) provides a witness `y` with `ψ ∈ f(y)`, but does NOT record the guard information (that `φ ∈ f(r)` for intermediate `r`). The `EliminationResult` structure at line 693 of CounterexampleElimination.lean includes `c5_forward_witness` which only guarantees `∃ y ∈ val.dom, pc.x < y ∧ pc.η ∈ val.f y` — no guard.

**Comment at line 596-598**:
> "Strengthening `EliminationResult.c5_forward_witness` to include guard info (the guard IS checked in `eliminate_potential_counterexample` at line 728 but discarded from the result type)."

**Resolution paths**:
1. **Strengthen EliminationResult**: Add guard info to `c5_forward_witness` output type
2. **Use limit_g directly**: At the limit, `limit_g` encodes the guard condition by construction. The issue is connecting `limit_g` to the Cantor isomorphism used in `cantor_bfmcs`
3. **Derive from C3**: If C3 and C5 are both available at the limit, the guard follows: `U(φ, ψ) ∈ f(x)` gives `φ ∈ g(x, y)` by C5, and `g(x, y) ⊆ f(r)` by C3 for `x < r < y`

## Plan v35 Misalignment Summary

| Plan Phase | Plan's Assumption | Reality |
|------------|-------------------|---------|
| Phase 3: Restructure Lemma 2.6 | Closes sorry sites, feeds C4 phase | Lemma 2.6 has zero callers; C4 doesn't use it |
| Phase 4: Archive dead code | Dead code from Phase 3 changes | The "dead code" was already dead before Phase 3 |
| Phase 5: Rewrite Lemma 2.7 | Feeds FUC/FSC phase | Lemma 2.7 has zero callers; FUC/FSC doesn't use it |
| Phase 6: Close C4/C4' | Uses lemma_2_6_splitting | C4 uses c2' (BurgessR3Maximal for adjacent pairs), not lemma_2_6 |
| Phase 7: Close FUC/FSC | Uses C5 + Lemma 2.7 | FUC uses limit_g + Cantor iso, not Lemma 2.7 |

## Phase 2 Finding: A7a Unsound

Phase 2 discovered that A7a (`linear_until_a7a` / `linear_since_a7a`) is **unsound** under open-guard Until semantics. The axiom was removed entirely (~500 lines). This eliminates the plan's Phase 5 approach (Lemma 2.7 via A7a). Any future attempt at Lemma 2.7 must use BX7 instead.

## Recommendations

### Immediate Actions

1. **Archive sorries 1-3 to Boneyard**: `g_content_sub_B`, `h_content_sub_B`, `splitting_seed_consistent`, `lemma_2_6_splitting`, `lemma_2_7`, and all supporting helpers. These are dead code with no path to the goal.

2. **Revise plan** to target the 4 actual blockers directly.

### Revised Phase Structure (Proposed)

**Phase A: Re-establish c2' at finite stages** (Blocker A)
- Determine whether `g_content(f(w)) ⊆ f(w_next)` is available for adjacent pairs in the omega_chain
- If yes: use `burgessR3Maximal_from_g_content_sub` to construct BurgessR3Maximal for each adjacent pair
- Re-add c2' to the omega_chain invariant or prove it per-step in `eliminate_C4_counterexample`
- This requires understanding how the g-value is assigned during point insertion

**Phase B: Close C4/C4' hard case** (Sorries 4-5)
- With c2' available, apply `burgessR3_gamma_not_in_B` (already proved at RRelation.lean:836) to get `γ.neg ∈ D` where D is an MCS
- This may also need `lemma_2_6_splitting` — but a SIMPLER version that only provides one BurgessR3Maximal (not two), using the g_content inclusion from c2'

**Phase C: Connect limit_g to FUC/FSC** (Sorries 6-7)
- Thread `limit_g` through the Cantor isomorphism to `cantor_bfmcs`
- Use C3 at the limit (`limit_g_c3`, already sorry-free) to derive the guard condition
- Alternative: strengthen `EliminationResult.c5_forward_witness` to include guard info

**Phase D: Final audit + ROADMAP update**

### Key Research Questions

1. Is `g_content(f(w)) ⊆ f(w_next)` maintained during point insertion? (Check `eliminate_potential_counterexample` G-propagation logic)
2. Can `burgessR3_gamma_not_in_B` directly close the C4 sorry, or does it need additional infrastructure?
3. How does the Cantor isomorphism in `cantor_bfmcs` relate to `limit_g`? Is `limit_g` already used in the BFMCS construction?

## Files Analyzed

| File | Lines | Key Contents |
|------|-------|-------------|
| PointInsertion.lean | ~1070 | Lemma 2.6/2.7 (dead), g_content_sub_B sorry (dead) |
| CounterexampleElimination.lean | ~730 | C4/C4' elimination with sorry at hard cases, EliminationResult structure |
| ChronicleToCountermodel.lean | ~660 | Cantor BFMCS, FUC/FSC sorry, dd_countermodel_chronicle |
| ChronicleConstruction.lean | ~940 | omega_chain (c0 only), limit_f/limit_g, C3/C5 at limit |
| ChronicleTypes.lean | ~500 | Chronicle/ValidChronicle definitions, c2'/C3/C4/C5 conditions |
| RRelation.lean | ~1530 | burgessR3, BurgessR3Maximal, Zorn extension, burgessR3_gamma_not_in_B |
