# Team Research Report: Task #58 - Model-Theoretic Glue Analysis

**Task**: Wire Completeness to Frame Conditions
**Date**: 2026-03-26
**Mode**: Team Research (4 teammates)
**Session**: sess_1774546432_d23eb0
**Focus**: Rigorous mathematical analysis of implementation blockers from v9 plan

## Summary

**All 4 teammates converge on the same conclusion: the team has been solving the wrong problem.** The 3 target sorries in FrameConditions/Completeness.lean are NOT about temporal coherence or backward chains. They are about **model-theoretic glue** — connecting the sorry-free `BFMCS_Bundle` algebraic construction to the semantic `valid_over` definition via `TaskModel`.

The core algebraic completeness path via `UltrafilterChain.lean` is **fully sorry-free**. The `deferralClosure` approach from prior plans was a red herring for the actual completeness sorries.

## Key Findings

### 1. The Precise Obstruction (Teammate A)

The gap at line 214 (`bundle_validity_implies_provability`) is:
```
valid_over Int φ → Nonempty ([] ⊢ φ)
```

The proof has the algebraic side complete:
1. `not_provable_implies_neg_consistent` (sorry-free)
2. `bundle_completeness_contradiction` (sorry-free)
3. These give: if not provable, not all MCS contain φ

**Missing**: connecting `valid_over Int φ` (semantic) to "all MCS contain φ" (algebraic). This requires building a canonical `TaskModel` from `BFMCS_Bundle` and showing the `valid_over` hypothesis applies to it.

### 2. Bundle-Level Completeness Path (Teammate B)

`construct_bfmcs_bundle` is **completely sorry-free** (UltrafilterChain.lean:2853). All component lemmas proven:
- `boxClassFamilies_bundle_forward_F` — F-witnesses exist in SOME family
- `boxClassFamilies_bundle_backward_P` — P-witnesses exist in SOME family
- `boxClassFamilies_modal_forward/backward` — Box propagation

**Critical insight**: Bundle-level coherence allows **cross-family witnesses**, completely avoiding the `constrained_predecessor` problem that blocked family-level approaches.

G/H backward cases are **non-issues** at bundle level because:
- Bundle uses contraposition: if `Box phi` not in MCS, `Diamond(neg phi)` gives witness W' via `box_theory_witness_exists`
- The shifted chain from W' IS in the bundle
- This is PROVABLE (unlike the singleton-Omega approach)

### 3. Backward Chain Status (Teammate C)

Backward chain construction is mathematically symmetric to forward chain (~700 LOC, mostly mechanical). However:
- **NOT NEEDED for completeness** (only for full biconditional truth lemma)
- Forward-only truth lemma suffices for the completeness argument
- If ever needed: `h_content` and `pastDeferralDisjunctions` already exist; only `f_step_blocking_formulas_restricted` and `past_boundary_resolution_set` are missing

Alternative: `swap_temporal` could convert P-requirements to F-requirements, reusing forward infrastructure (medium confidence, higher risk).

### 4. The Real Problem (Teammate D)

**The 3 sorries are THREE DIFFERENT problems:**

| Sorry | Line | Actual Requirement | Relationship |
|-------|------|--------------------|-------------|
| `bundle_validity_implies_provability` | 214 | Model-theoretic glue: BFMCS_Bundle → TaskModel/valid_over | **CORE GAP** |
| `dense_completeness_fc` | 120 | Derives from Int completeness via embedding | Depends on line 214 |
| `discrete_completeness_fc` | 163 | `discrete_Icc_finite_axiom` dependency + Int completeness | Depends on line 214 + task 60 |

**Lines 120 and 163 are derivable from line 214** once Int completeness is proven.

### 5. Forward-Only Truth Lemma Suffices

Completeness only needs the **forward direction**: `phi ∈ M → truth_at ... phi`.

For F/P cases in forward direction:
- `F(phi) ∈ M` → exists witness with phi: **bundle-level suffices!**
- `P(phi) ∈ M` → exists witness with phi: **bundle-level suffices!**

The backward direction (truth → MCS membership) is only needed for the full biconditional, which is NOT required for completeness.

## Synthesis

### Conflicts Resolved

**Conflict 1**: Is backward chain necessary?
- Teammate A: YES for full truth lemma
- Teammate D: NO for completeness
- *Resolution*: **Forward-only truth lemma suffices for completeness**. Backward chain is only needed for the full biconditional truth lemma, which is a separate concern.

**Conflict 2**: Is deferralClosure relevant?
- Prior research: Central to the approach
- Teammates A, B, D: Irrelevant for the actual sorries
- *Resolution*: **DeferralClosure is a red herring for the completeness sorries.** The gap is model-theoretic glue, not temporal coherence. The v9 plan targeted the wrong obstruction.

**Conflict 3**: Is this "just plumbing" or deep math?
- Teammates A, B: "Model-theoretic plumbing, not deep proof theory"
- Teammate D: More nuanced — the connection requires a bundle truth lemma
- *Resolution*: **It's non-trivial plumbing.** A bundle truth lemma variant is needed, but the mathematical content is already captured by existing sorry-free infrastructure. The work is in adapting the existing `parametric_shifted_truth_lemma` to work with bundle-level coherence instead of family-level coherence.

### Gaps Identified

1. **No `BFMCS_Bundle`-to-`TaskModel` conversion exists** — this is the core gap
2. **No bundle-level truth lemma exists** — needed to connect MCS membership to semantic truth
3. **No proof that the canonical bundle model satisfies `valid_over` constraints** — needed to apply the hypothesis
4. **The F/P cases in the truth lemma for bundle-level are unproven** — though the witnesses exist (sorry-free), the truth lemma proof needs adaptation

### Recommendations

**The mathematically correct path with no compromises:**

**Phase 1**: Create a bundle-level truth lemma variant
- Adapt `parametric_shifted_truth_lemma` to use bundle-level coherence
- Only the forward direction is needed: `phi ∈ fam.mcs t → truth_at BundleModel phi`
- The F/P cases use `bundle_forward_F` / `bundle_backward_P` (sorry-free)
- The Box case uses `modal_forward` / `modal_backward` (sorry-free)

**Phase 2**: Build TaskModel from BFMCS_Bundle
- Define `BundleCanonicalTaskModel` (WorldState = Set Formula, Valuation = atom membership)
- Define `BundleCanonicalOmega` from bundle families via `parametric_to_history`
- Prove the TaskFrame properties (reflexivity, transitivity of accessibility)

**Phase 3**: Wire to valid_over
- Show the canonical bundle model is a valid TaskModel over Int
- Apply `h_valid : valid_over Int φ` to get truth at all points
- Connect truth back to MCS membership via bundle truth lemma
- Eliminate `bundle_validity_implies_provability` sorry (line 214)

**Phase 4**: Derive dense/discrete completeness
- `dense_completeness_fc` follows from Int completeness via embedding
- `discrete_completeness_fc` follows similarly (may still depend on `discrete_Icc_finite_axiom` from task 60)

## Why v9 Plan Failed

The v9 plan (deferral-restricted task construction) targeted the WRONG obstruction:
1. **`deferralClosure_closed_under_box_class`** was mathematically impossible as stated
2. **Backward chain infrastructure** is not needed for completeness
3. **Family-level coherence** is not needed — bundle-level suffices
4. **The actual gap** (model-theoretic glue) was never addressed by any phase of the v9 plan

The correct approach is to work with the existing sorry-free `BFMCS_Bundle` infrastructure and build the missing model-theoretic bridge to `valid_over`.

## Teammate Contributions

| Teammate | Angle | Status | Key Contribution | Confidence |
|----------|-------|--------|------------------|------------|
| A | Mathematical obstruction | completed | Precise gap analysis: forward chain done, backward missing but avoidable | HIGH |
| B | Bundle-level path | completed | construct_bfmcs_bundle is fully sorry-free; G/H cases non-issues | HIGH |
| C | Backward chain analysis | completed | Symmetric construction mapped; ~700 LOC but NOT needed for completeness | HIGH |
| D | Devil's advocate | completed | **Reframed the problem**: sorries are model glue, not temporal coherence | HIGH |

## Mathematical Summary

```
EXISTING (sorry-free):
  construct_bfmcs_bundle M0 h_mcs : BFMCS_Bundle           [UltrafilterChain.lean]
  bundle_completeness_contradiction : ¬prov φ → ¬(∀ M, MCS M → φ ∈ M)  [UltrafilterChain.lean]
  parametric_shifted_truth_lemma : h_tc → (φ ∈ M ↔ truth_at ...)       [ParametricTruthLemma.lean]

MISSING:
  bundle_truth_lemma_forward : BFMCS_Bundle → (φ ∈ M → truth_at ...)   [NEEDED]
  bundle_to_task_model : BFMCS_Bundle → TaskModel Int                   [NEEDED]
  bundle_model_valid : valid_over Int φ → φ true in bundle model        [NEEDED]

TARGET:
  bundle_validity_implies_provability : valid_over Int φ → Nonempty ([] ⊢ φ)  [line 214]
  dense_completeness_fc : (derives from above)                                [line 120]
  discrete_completeness_fc : (derives from above + task 60)                   [line 163]
```

## References

- `FrameConditions/Completeness.lean` — Target sorries (lines 120, 163, 214)
- `Metalogic/Algebraic/UltrafilterChain.lean` — Sorry-free bundle construction
- `Metalogic/Algebraic/ParametricTruthLemma.lean` — Existing truth lemma (family-level)
- `Metalogic/Bundle/SuccChainTruth.lean` — Prior truth lemma attempts (documents failures)
- `Metalogic/Bundle/SuccChainFMCS.lean` — Forward chain infrastructure
- `FrameConditions/Validity.lean` — valid_over definition
- `Semantics/TaskFrame.lean` — TaskFrame structure
