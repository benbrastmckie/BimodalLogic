# Teammate B Findings: Alternative Approaches for Frame.lean Eventuality Sorries

## Key Findings

### 1. These Sorries Can Be Bypassed -- BXCanonical Is an Isolated Module

**The 4 Frame.lean sorries are completely isolated from the active completeness path.** The dependency graph shows:

- **Active path (Path B)**: `completeness_over_Int` -> `dovetailed_bundle_validity_implies_provability` -> `DovetailedFMCS_forward_F`/`DovetailedFMCS_backward_P` (sorry, in DovetailedChain.lean) + `forward_until_since_coherent` (sorry, in FrameConditions/Completeness.lean)
- **BXCanonical path (this task)**: `bx_completeness` -> Frame.lean sorries + canonical model embedding sorry

`bx_completeness` is **never referenced** outside `BXCanonical/Completeness.lean`. The only import of BXCanonical is the barrel file `Metalogic/Metalogic.lean` (which imports everything). No other module depends on `bx_until_eventuality_resolution`, `bx_until_backward`, `bx_since_eventuality_resolution`, or `bx_since_backward`.

**Implication**: These 4 sorries could be replaced with `sorry` annotations marked as deprecated, or the entire BXCanonical module could be archived to Boneyard, without affecting any active completeness path.

### 2. Task 83 Success Does NOT Make These Sorries Irrelevant (Different Blockers)

Task 83 targets `succ_chain_restricted_forward_F` / `succ_chain_restricted_backward_P` in UltrafilterChain.lean. These are on the **restricted coherence path** which is architecturally distinct from BXCanonical:

| Aspect | BXCanonical (task 89) | Restricted path (task 83) |
|--------|----------------------|--------------------------|
| World type | BXPoint (raw MCS) | SuccChainFMCS (Int-indexed chain) |
| Ordering | bx_le (g_content inclusion) | Int ordering |
| Blocker | bx_le non-linearity + G-content mismatch | X-vs-G mismatch in Lindenbaum steps |
| Scope | All formulas | deferralClosure(root) only |

However, the **root cause is shared**: Until/Since formulas don't propagate through g_content-based ordering. The "X-vs-G mismatch" appears in both DovetailedChain.lean and Frame.lean. If task 83 finds a technique to resolve this mismatch, it *might* transfer to BXCanonical, but the BXCanonical version faces the additional burden of proving bx_le linearity on intervals.

### 3. Signature Change Approach: Viable but Requires TruthLemma Rework

The current signatures demand a **universal guard** over ALL BXPoints in [w,v):

```lean
∀ u : BXPoint, bx_le w u → bx_le u v ∧ ¬bx_le v u → φ ∈ u.formulas
```

This quantifies over ALL maximal consistent sets, which is the core difficulty. Possible weakenings:

**(a) Restrict to chain-reachable points**: Change the guard to quantify only over points reachable via a specific successor chain, not all BXPoints. This would require:
- Adding a chain parameter to the type signature
- Modifying `until_iff_mcs` in TruthLemma.lean to match
- Making the truth lemma chain-relative rather than universal

This essentially converts BXCanonical into a chain-based construction like SuccChainFMCS, losing its architectural distinctiveness.

**(b) Add a linearity hypothesis**: Change signatures to require `bx_le_linear_on_interval w v` as an additional hypothesis:

```lean
(h_linear : ∀ u₁ u₂ : BXPoint, bx_le w u₁ → bx_le u₁ v → bx_le w u₂ → bx_le u₂ v →
    bx_le u₁ u₂ ∨ bx_le u₂ u₁)
```

This makes the proofs straightforward but pushes the burden to callers. The truth lemma would need to provide this linearity, which is equally hard to prove in general.

**(c) Weaken to existential guard**: Replace the universal guard with an existential witness of a path:

```lean
∃ path : List BXPoint, path.head? = some w ∧ path.getLast? = some v ∧
  (∀ p ∈ path.dropLast, φ ∈ p.formulas) ∧ ...
```

This is provable (construct a 2-element path [w, v] using BX10 for the witness and BX9 for the guard at w), but the truth lemma's Until semantics requires the universal guard for soundness.

**Assessment**: Option (a) is most viable but eliminates the rationale for having BXCanonical as a separate module.

### 4. Semantic Model Shortcut Via SuccChainFMCS: Blocked

The idea: build an Int-indexed model using SuccChainFMCS, prove eventuality there, then transfer back to BXPoint level.

**Blocked because**: The transfer requires showing that every BXPoint in [w,v) corresponds to some time point in the SuccChainFMCS chain. This is exactly the bx_le linearity problem in disguise. SuccChainFMCS chains visit specific MCS sequences; there's no guarantee that an arbitrary MCS u satisfying `bx_le w u ∧ bx_le u v` appears in any particular chain.

### 5. Completeness Without Eventuality Resolution

Known approaches in the literature:

**(a) Quasimodel / Mosaic approach** (GHR 1994, Reynolds 2003): Decomposes the model into local constraint-satisfaction pieces. Avoids building a single linear chain. This is the approach mentioned in the ROAD_MAP (task 83 report 24) but assessed as ~2000 LOC with linearization issues.

**(b) Algebraic / Topological approach**: Use the Lindenbaum algebra directly with ultrafilter topology. The algebraic path in this codebase (`Algebraic/`) is sorry-free up to `construct_bfmcs`, but `construct_bfmcs` faces the same temporal coherence gap.

**(c) Step-indexed / Fuel-based**: Repeatedly tried and failed (tasks 48, 67, 81 per ROAD_MAP). Fuel conflates F-nesting depth with persistence count.

**(d) Game-theoretic**: Adequacy games for temporal logics exist but have not been formalized in Lean 4 / Mathlib. Would be a research contribution but extremely high effort.

**No known approach avoids eventuality resolution entirely for Until-temporal logics.** The semantic content of Until inherently requires showing that the eventuality (psi) is eventually reached. All approaches must address this; they differ only in where and how.

### 6. The Real Completeness Path Has 8+ Sorries, Not Just These 4

The active completeness chain (`completeness_over_Int` via `dovetailed_bundle_validity_implies_provability`) has these sorries:

1. `DovetailedFMCS_forward_F` (DovetailedChain.lean) -- DEPRECATED, X-vs-G mismatch
2. `DovetailedFMCS_backward_P` (DovetailedChain.lean) -- DEPRECATED, X-vs-G mismatch
3. `forward_until_since_coherent` (FrameConditions/Completeness.lean, 3 sites) -- BLOCKED
4. `backward_until_since_coherent` step transfer (FrameConditions/Completeness.lean, 2 sites) -- sorry
5. `succ_chain_restricted_forward_F` (UltrafilterChain.lean) -- task 83
6. `succ_chain_restricted_backward_P` (UltrafilterChain.lean) -- task 83

The BXCanonical module's 4 sorries + 1 sorry (canonical model embedding in `bx_completeness`) add to this count but are NOT on any critical path.

## Recommended Approach

**Abandon these 4 sorries. Do not attempt to close them.**

Justification:
1. They are on a dead-end path. BXCanonical's `bx_completeness` has an additional sorry (canonical model embedding, line 154) that is independent of these 4 and equally hard.
2. Even if all 4 were closed, BXCanonical would still not provide a working completeness proof.
3. The active completeness path (Path B via restricted coherence) does not use BXCanonical at all.
4. The fundamental blocker (bx_le non-linearity + G-content mismatch) has been investigated extensively (tasks 85, 86, 88) and found to be architecturally insurmountable in the BXCanonical framework.
5. Engineering effort should focus on task 83's restricted coherence path, which has strictly more tractable sorries.

**Concrete action**: Either:
- **(Option A)** Archive BXCanonical to Boneyard and remove from the build. Clean, saves build time.
- **(Option B)** Keep BXCanonical as documentation/reference for the MCS-level truth lemma (which is valuable -- `until_iff_mcs`, `since_iff_mcs`, `box_iff_mcs`, etc. are correct modulo the 4 sorry'd helpers). Mark the sorries with `-- DEPRECATED: not on critical path` comments.

Option B is preferable because the sorry-free parts of BXCanonical (modal witness construction, G/H forward/backward, box preservation along bx_le) are valuable infrastructure that may be reusable.

## Evidence/Examples

### BXCanonical is self-contained (no external consumers)
```
$ grep -r "bx_completeness" --include="*.lean" | grep -v BXCanonical
# (empty -- no results)

$ grep -r "bx_until_eventuality" --include="*.lean" | grep -v Frame.lean
Theories/Bimodal/Metalogic/BXCanonical/TruthLemma.lean  # only consumer
```

### The fundamental blocker documented in Frame.lean (line 610-616)
```
φ U ψ ∈ w does NOT imply G(φ U ψ) ∈ w, so the formula
does not propagate forward through g_content.
```

This is the same X-vs-G mismatch documented in DovetailedChain.lean (line 37-48) and acknowledged as architecturally insurmountable in the ROAD_MAP (dead end #7).

### Dovetailed path also sorry'd on the same root cause
`DovetailedFMCS_forward_F` and `DovetailedFMCS_backward_P` are both sorry'd with comment: "DEPRECATED: architectural limitation (X-vs-G mismatch in Until persistence through Lindenbaum steps)". This confirms the blocker is not specific to BXCanonical but fundamental to all g_content-based approaches.

## Confidence Level

**High (90%)** that these sorries cannot be closed within the current BXCanonical architecture.

**High (95%)** that closing them would not contribute to the active completeness path.

**Medium (70%)** that the recommended approach (Option B: keep as reference, mark deprecated) is optimal. The 30% uncertainty is whether someone might find a novel technique for bx_le linearity that works specifically for BXCanonical but not for the chain-based approaches.
