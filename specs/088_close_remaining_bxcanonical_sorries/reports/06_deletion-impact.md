# Research Report: Deletion Impact Analysis for Constant-History Infrastructure

**Task**: 88 - Close remaining BXCanonical sorries
**Date**: 2026-04-10
**Focus**: Impact assessment for removing `usf_completeness`, `fragment_completeness`, and all constant-history infrastructure

## Summary

The constant-history approach (`constant_history`, `modal_omega`, `fragment_truth_iff`, `fragment_completeness`, `usf_completeness`) is entirely self-contained within `CanonicalEmbedding.lean`. Removing it is **clean and low-risk**: no other file uses any definition from this infrastructure. The only downstream reference is a comment in `Completeness.lean`. The sorry-free content in TruthLemma.lean (`G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs`) is NOT part of the constant-history infrastructure and must be preserved.

## Blast Radius

### Files affected by deletion

| File | Impact | Action |
|------|--------|--------|
| `CanonicalEmbedding.lean` | **DELETE ENTIRE FILE** (434 lines) | All content is constant-history infrastructure or fragment completeness |
| `Completeness.lean` | Comment-only reference at line 145 | Update comments to remove `fragment_completeness` mention |
| `BXCanonical.lean` | Import line 3 | Remove `import Bimodal.Metalogic.BXCanonical.CanonicalEmbedding` and update docstring |

### Files NOT affected

| File | Why safe |
|------|---------|
| `TruthLemma.lean` | Does NOT import CanonicalEmbedding; `G_iff_mcs`, `H_iff_mcs`, `box_iff_mcs` are MCS-level, not model-level |
| `Frame.lean` | Independent; defines `BXPoint`, `bx_le`, forward/backward witnesses |
| All Bundle/ files | Independent architecture; no BXCanonical cross-references |
| All Algebraic/ files | Independent architecture |
| Tests/ | No references to any constant-history infrastructure |

### Definitions being removed (all in CanonicalEmbedding.lean)

| Definition | Lines | Sorry-free? | Notes |
|------------|-------|-------------|-------|
| `temporalFree` | 63-71 | Yes | Fragment predicate; unused outside this file |
| `untilSinceFree` | 78-86 | Yes | Fragment predicate; unused outside this file |
| `temporalFree_imp_untilSinceFree` | 91-101 | Yes | Unused outside this file |
| `canonical_task_frame` | 108-140 | Yes | BXPoint-based TaskFrame on Int; unused outside this file |
| `constant_history` | 142-149 | Yes | The problematic trivialization |
| `constant_history_shift` | 152-157 | Yes | Shift invariance of constant history |
| `canonical_valuation` | 162-167 | Yes | Atom valuation for BXPoints |
| `modal_omega` | 170-171 | Yes | Set of constant histories through modal equivalence class |
| `constant_history_mem_modal_omega` | 173-175 | Yes | |
| `constant_history_mem_modal_omega_of_equiv` | 177-180 | Yes | |
| `modal_omega_shift_closed` | 182-190 | Yes | |
| `modal_omega_eq_of_equiv` | 186-190 | Yes | |
| `modal_omega_eq_of_bx_le` | 197-199 | Yes | |
| `fragment_truth_iff` | 213-266 | Yes | Temporal-free truth bridge on constant histories |
| `neg_consistent_of_not_derivable'` | 274-299 | Yes | Private duplicate of Completeness.lean's version |
| `fragment_completeness` | 310-321 | Yes | Temporal-free completeness (correct but superseded) |
| `valid_of_valid_all_future` | 336-339 | Yes | `valid G(phi) -> valid phi`; **may have value** |
| `valid_of_valid_all_past` | 344-347 | Yes | `valid H(phi) -> valid phi`; **may have value** |
| `valid_of_valid_box` | 355-358 | Yes | `valid box(phi) -> valid phi`; **may have value** |
| `usf_completeness` | 382-432 | **NO (1 sorry)** | The problematic theorem |

### Definitions to consider PRESERVING (relocating, not deleting)

Three validity reduction lemmas are correct, sorry-free, and potentially useful for any completeness approach:

1. `valid_of_valid_all_future` — `valid G(φ) → valid φ` (uses reflexivity of temporal order)
2. `valid_of_valid_all_past` — `valid H(φ) → valid φ` (symmetric)
3. `valid_of_valid_box` — `valid □φ → valid φ` (uses τ ∈ Omega)

These could be relocated to `Semantics/Validity.lean` where they logically belong. They are pure semantic facts, not dependent on any canonical model construction.

## Sorry Impact

| Metric | Before deletion | After deletion | Change |
|--------|-----------------|----------------|--------|
| Sorries in CanonicalEmbedding.lean | 1 (line 418) | 0 (file deleted) | -1 |
| Sorries in Completeness.lean | 1 (line 160) | 1 (unchanged) | 0 |
| Sorries in BXCanonical/ total | 2 actual | 1 actual | -1 |
| Sorry-free theorems removed | ~15 definitions | -- | Loss of `fragment_completeness` (correct but limited) |

**Net effect**: Removing 1 sorry, removing ~15 sorry-free definitions (all self-contained, none used elsewhere), and deleting a dead-end proof strategy.

## What to guard against in ROAD_MAP.md

The constant-history approach fails for a **fundamental mathematical reason**, not an engineering gap:

1. **Constant histories collapse temporal structure**: On `constant_history w`, `truth_at G(φ) = truth_at φ` because all times map to the same state. This means G is indistinguishable from identity, making any truth bridge for G inside imp impossible.

2. **Fragment completeness is a dead end**: `fragment_completeness` for temporal-free formulas is correct but cannot be extended to G/H. Any approach that tries to "incrementally extend" from temporal-free to USF by adding G/H to a constant-history model will fail.

3. **The imp case is inherently bidirectional**: The forward bridge for `ψ → χ` requires the backward bridge for `ψ`. No "forward-only" truth bridge can handle imp. This means ANY model used for the completeness proof must support full bidirectional truth bridges, which requires histories visiting ALL bx_le-related MCS points.

### Recommended ROAD_MAP.md entry

```markdown
## Anti-Pattern: Constant-History Completeness

**Status**: PERMANENTLY REJECTED (rounds 1-5 of task 88 research)

Do NOT attempt completeness proofs using constant histories, fragment-based
incremental extension, or any model where all times map to the same state.
These approaches fail because:
- G collapses to identity on constant histories (mathematical impossibility)
- The imp truth bridge is inherently bidirectional (forward uses backward for antecedent)
- Fragment completeness cannot extend to G/H — the gap is unbridgeable

The correct approach uses the Bundle architecture (BFMCS + temporal coherent families)
where histories visit all bx_le-related MCS points, providing full bidirectional truth
bridges for all connectives simultaneously.
```

## Recommendation

**Delete `CanonicalEmbedding.lean` entirely.** The cleanup is:

1. Delete `Theories/Bimodal/Metalogic/BXCanonical/CanonicalEmbedding.lean`
2. Remove import from `BXCanonical.lean` line 3
3. Update docstring in `BXCanonical.lean` line 15
4. Update comments in `Completeness.lean` lines 144-159
5. Optionally relocate 3 validity reduction lemmas to `Semantics/Validity.lean`
6. Add anti-pattern entry to ROAD_MAP.md
7. Run `lake build` to confirm no breakage

**Estimated effort**: 1 hour
**Risk**: Very low — no downstream dependencies
