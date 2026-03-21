# Research Report: Task #1006 — WorldHistory Convexity Blocker Analysis

**Task**: 1006 - canonical_taskframe_completeness
**Date**: 2026-03-20
**Mode**: Team Research (2 teammates)
**Session**: sess_1774020213_d32e65

## Summary

The two remaining sorries in `FlagBFMCSRatBundle.lean` (`convex` and `shifted_truth_lemma`) stem from a fundamental architectural mismatch: the current construction embeds a discrete chain into Rat, creating a non-convex domain that cannot satisfy `WorldHistory.convex`. Both teammates independently confirmed the `convex` sorry is **provably false** — it cannot be closed with the current domain definition. The resolution requires a different construction strategy, not a proof technique.

Two viable approaches emerged:
1. **Dovetailed Flag + ℤ isomorphism** (Teammate B, recommended) — use a self-contained dovetailed chain as the basis, mapped to ℤ
2. **BFMCS Rat via parametric pipeline** (Teammate A) — redirect Phase 3 to build multi-family BFMCS Rat and use `parametric_to_history`

Both approaches converge on using the parametric pipeline (`parametric_to_history` → `parametric_shifted_truth_lemma`) to obtain a WorldHistory with a trivially convex full domain.

## Key Findings

### 1. The `convex` sorry is provably false (BOTH teammates agree)

The image of a countable discrete chain under any order-embedding into Rat is **never convex**. Between any two consecutive chain image points, there are infinitely many rationals not in the image. This is a mathematical fact, not a proof engineering difficulty.

### 2. Simple domain extensions all fail (Teammate B analysis)

Every attempt to "fill the gaps" by extending the state function to intermediate rationals breaks `respects_task` due to **CanonicalR irreflexivity**:
- Constant extension: `d > 0` requires `CanonicalR M M`, but CanonicalR is irreflexive
- Interpolation: Same problem — two distinct rationals mapping to the same MCS
- Left/right-constant: Same irreflexivity issue

This is not a proof difficulty but a **mathematical impossibility** with the `parametric_canonical_task_rel` definition.

### 3. The current construction bypasses the planned pipeline (Teammate A)

The v3 plan specified the pipeline:
```
BFMCS Rat → parametric_to_history → parametric_shifted_truth_lemma
```
The current Phase 3 implementation (`shiftedFlagWorldHistory`) is an ad-hoc direct WorldHistory construction that was **never part of the plan**. It bypasses `parametric_to_history`, which is specifically designed to handle convexity internally.

### 4. Cross-Flag witness problem is the deeper blocker (Teammate B)

Even if `convex` were resolved, `shifted_truth_lemma` has a second blocker: the G-backward case requires temporal witnesses to exist **in the same Flag's domain**. But `canonical_forward_F` witnesses may reside in a **different Flag**. This cross-Flag witness problem is inherent to single-Flag WorldHistory constructions.

### 5. Dovetailed chains resolve the cross-Flag problem (Teammate B)

`DovetailedBuild` (in `StagedConstruction/DovetailedBuild.lean`) constructs chains that are **self-contained** — F/P witnesses are placed inside the chain during construction. A dovetailed chain's Flag contains all needed temporal witnesses, eliminating the cross-Flag problem entirely.

## Synthesis

### Conflict: Which Construction Strategy?

**Teammate A** recommends the multi-family BFMCS Rat pipeline (original v3 plan approach):
- Build `BFMCS Rat` from `FlagBFMCS` (all Flags contribute families)
- Use `parametric_to_history` for convex WorldHistory
- Use `parametric_shifted_truth_lemma` for the truth lemma

**Teammate B** recommends the dovetailed chain + ℤ isomorphism:
- Use `DovetailedBuild` to construct a self-contained Flag F₀
- Map F₀ order-isomorphically to ℤ
- Build FMCS ℤ directly
- Use `parametric_to_history` for convex WorldHistory

### Resolution: Dovetailed Flag + ℤ is Superior

The dovetailed chain approach is recommended because it **resolves both blockers simultaneously**:

| Issue | Multi-family BFMCS Rat | Dovetailed Flag + ℤ |
|-------|----------------------|---------------------|
| Convexity | Resolved via `parametric_to_history` | Resolved via full ℤ domain |
| Cross-Flag witnesses | Requires multi-family coherence proofs | Eliminated by construction |
| FMCSTransfer surjectivity | Requires `embed_retract_eq` for ALL d (blocked for Rat) | Bijection to ℤ is surjective |
| Truth lemma | Needs parametric pipeline + family tracking | Single-Flag, direct proof |
| Existing infrastructure | `FMCSTransfer.lean` (sorry-free) | `DovetailedBuild.lean` + ℤ |
| New work needed | BFMCS Rat multi-family construction | DovetailedBuild → Flag connection + ℤ iso |

The multi-family approach has a subtle remaining difficulty: `FMCSTransfer` requires `embed_retract_eq : embed (retract d) = d` for ALL d, which implies surjectivity. A countable chain cannot surject onto Rat. This means the Rat-based FMCSTransfer approach is **also blocked** at the same point, just more subtly.

The ℤ-based approach avoids this because a countable discrete linear order without endpoints IS order-isomorphic to ℤ, giving a genuine bijection.

### Gaps Identified

1. **DovetailedBuild → Flag connection**: The `DovetailedBuild` constructs a chain, but its output needs to be connected to the `Flag` (maximal chain) infrastructure. This connection may need to be established.

2. **ℤ isomorphism proof**: Proving that a dovetailed chain is order-isomorphic to ℤ requires showing it is:
   - Countable (from CanonicalMCS countability)
   - Discrete (each element has an immediate successor and predecessor)
   - Without endpoints (guaranteed by dovetailed construction's F/P witnesses)

3. **Group structure pullback**: The AddCommGroup structure on ℤ needs to be transferred to `ChainFMCSDomain F₀` via the isomorphism. This is straightforward but needs careful construction.

4. **FMCS ℤ construction**: Building `FMCS ℤ` from the dovetailed chain's MCS assignments, then proving `forward_G`/`backward_H`/`forward_F`/`backward_P` using the chain's self-containment properties.

## Recommendations

### Primary Recommendation: Dovetailed Flag + ℤ Approach

**Phase structure for revised plan**:

1. **Phase A: DovetailedBuild → Flag connection**
   - Show that DovetailedBuild produces a structure usable as a Flag
   - Extract the self-containment properties (F/P witnesses in chain)

2. **Phase B: ℤ isomorphism**
   - Prove the dovetailed chain is order-isomorphic to ℤ
   - Construct the bijection explicitly (enumerate chain elements)
   - Transfer AddCommGroup from ℤ

3. **Phase C: FMCS ℤ construction**
   - Build FMCS on ℤ via the isomorphism
   - Prove temporal properties using chain self-containment
   - Feed into `parametric_to_history` for WorldHistory

4. **Phase D: Completeness theorem**
   - Apply `parametric_shifted_truth_lemma`
   - Wire the final completeness statement

### Alternative: Simplified Direct Approach

If the DovetailedBuild infrastructure proves too complex to connect:

1. Accept that `WorldHistory.convex` cannot be proven for discrete embeddings
2. The existing `FlagBFMCS_completeness` theorem (in `FlagBFMCSCompleteness.lean`) is **already sorry-free** using the internal `satisfies_at` relation
3. Build a thin bridge: `satisfies_at ↔ truth_at` for the specific canonical model
4. This avoids constructing a WorldHistory entirely

### What NOT to Do

- Do NOT try to fix the `convex` sorry in the current construction — it is provably false
- Do NOT extend the domain to all of Rat with constant states — `respects_task` fails by irreflexivity
- Do NOT modify `WorldHistory` to drop convexity — this changes the core semantics
- Do NOT interpolate between chain points — same irreflexivity failure

## Teammate Contributions

| Teammate | Angle | Status | Confidence | Key Insight |
|----------|-------|--------|------------|-------------|
| A | Semantic/structural analysis | completed | high | The shiftedFlagWorldHistory bypasses the planned pipeline; `parametric_to_history` handles convexity |
| B | Alternative constructions | completed | high | All simple extensions fail by CanonicalR irreflexivity; dovetailed chain + ℤ is the correct path |

## References

| File | Relevance |
|------|-----------|
| `Theories/Bimodal/Semantics/WorldHistory.lean` | WorldHistory definition with convex field |
| `Theories/Bimodal/Metalogic/Bundle/FlagBFMCSRatBundle.lean` | Current blocked implementation |
| `Theories/Bimodal/Metalogic/Bundle/ChainFMCS.lean` | Chain structure and ordering |
| `Theories/Bimodal/Metalogic/Bundle/FMCSTransfer.lean` | Transfer infrastructure |
| `Theories/Bimodal/Metalogic/Parametric/ParametricRepresentation.lean` | `parametric_to_history` |
| `Theories/Bimodal/Metalogic/Parametric/ParametricTruthLemma.lean` | `parametric_shifted_truth_lemma` |
| `Theories/Bimodal/Metalogic/StagedConstruction/DovetailedBuild.lean` | Dovetailed chain construction |
| `Theories/Bimodal/Metalogic/Algebraic/ParametricCanonical.lean` | `parametric_canonical_task_rel` |

## Next Steps

1. **Revise plan** (`/revise 1006`) to adopt the dovetailed Flag + ℤ approach
2. **Investigate DovetailedBuild** outputs to understand the connection to Flag
3. **Determine discreteness** of dovetailed chains (are they order-isomorphic to ℤ?)
4. Remove or deprecate the current `shiftedFlagWorldHistory` construction
