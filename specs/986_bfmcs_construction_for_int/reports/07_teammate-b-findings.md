# Teammate B Findings: Task 986 Alternative Paths

**Session**: sess_1773785524_aedf5c
**Date**: 2026-03-17
**Role**: Mathematically correct path forward — alternative to D=Int

---

## Key Findings

- `valid phi` quantifies over ALL `D : Type` with `AddCommGroup D`, `LinearOrder D`, `IsOrderedAddMonoid D`. Completeness only requires ONE countermodel in ONE specific D — it does NOT need D=Int.
- `CanonicalMCS` has a `Preorder` (reflexive closure of `CanonicalR`) but NOT `AddCommGroup`, so it cannot be used directly as the `D` parameter to `TaskFrame`.
- `temporal_coherent_family_exists_CanonicalMCS` provides `FMCS CanonicalMCS` (not `FMCS D`). This is indexed by `CanonicalMCS`, not by `Int` or any additive group.
- `AlgebraicBaseCompleteness.lean` already recognizes the correct path: it needs a BFMCS over some `D` with `AddCommGroup`. The D-parametric algebraic infrastructure (`ParametricCanonicalTaskFrame D`, `ParametricCanonicalTaskModel D`, `ShiftClosedParametricCanonicalOmega`) requires `AddCommGroup D`.
- The `parametric_algebraic_representation_conditional` theorem requires `construct_bfmcs : Set Formula → SetMaximalConsistent M → Σ' (B : BFMCS D) ...`, where `D` must be the SAME type as the task frame's duration type.
- The simplest valid D for completeness is `Int` — it satisfies all required typeclasses — but the F/P coherence for BFMCS Int requires dovetailing, which is the linearization obstruction identified in prior research.

---

## The D=Int Question: Is It Actually Necessary?

### What `valid phi` Requires

```lean
def valid (φ : Formula) : Prop :=
  ∀ (D : Type) [AddCommGroup D] [LinearOrder D] [IsOrderedAddMonoid D]
    (F : TaskFrame D) (M : TaskModel F) (Omega : ...) ...
    truth_at M Omega τ t φ
```

For completeness (contrapositive: `¬provable φ → ¬valid φ`), we need to exhibit:
- ONE specific `D` (any additive ordered group)
- ONE specific `TaskFrame D`
- ONE specific `TaskModel`
- ONE specific history `τ` and time `t`
- where `¬truth_at ... φ`

**Conclusion**: D=Int is not necessary. Any `D` with `AddCommGroup D, LinearOrder D, IsOrderedAddMonoid D` suffices for the countermodel.

### Why D=CanonicalMCS Cannot Work Directly

`CanonicalMCS` has `Preorder` but NOT `AddCommGroup`. The `TaskFrame` structure requires:
- `AddCommGroup D` (zero, addition, negation)
- `LinearOrder D` (total order)
- `IsOrderedAddMonoid D` (order-compatible addition)

`CanonicalMCS` satisfies none of these. The `FMCS CanonicalMCS` construction (which IS sorry-free) cannot be directly plugged into the parametric algebraic infrastructure which expects `D : AddCommGroup`.

---

## Why `temporal_coherent_family_exists_CanonicalMCS` Is Sorry-Free

The theorem signature:

```lean
theorem temporal_coherent_family_exists_CanonicalMCS
    (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    ∃ (fam : FMCS CanonicalMCS) (root : CanonicalMCS),
      (∀ gamma ∈ Gamma, gamma ∈ fam.mcs root) ∧
      (∀ t : CanonicalMCS, ∀ φ : Formula,
        Formula.some_future φ ∈ fam.mcs t → ∃ s : CanonicalMCS, t ≤ s ∧ φ ∈ fam.mcs s) ∧
      (∀ t : CanonicalMCS, ∀ φ : Formula,
        Formula.some_past φ ∈ fam.mcs t → ∃ s : CanonicalMCS, s ≤ t ∧ φ ∈ fam.mcs s)
```

This is sorry-free because:
1. The domain `CanonicalMCS` contains ALL maximal consistent sets
2. `canonical_forward_F` gives a witness W that IS a CanonicalMCS element (no reachability check)
3. `canonical_backward_P` gives a witness W that IS a CanonicalMCS element (same reason)
4. The "witness already in domain" property bypasses all linearization problems entirely

Note: it uses `≤` (not `<`), so this proves `FMCS CanonicalMCS` but NOT `TemporalCoherentFamily CanonicalMCS` (which needs strict `<`). The FMCS structure's `forward_F` and `backward_P` use strict inequality (`t < s`).

**Wait** — looking at `TemporalCoherence.lean`: `TemporalCoherentFamily` uses strict `<`, but `BFMCS.temporally_coherent` also uses strict `<`. The `temporal_coherent_family_exists_CanonicalMCS` theorem uses `≤`. This is a subtle mismatch that needs attention in any implementation.

---

## Alternative Paths

| Path | Feasibility | Trade-offs |
|------|------------|------------|
| **A: Complete D=Int dovetailing** | Very Low | Linearization obstruction is structural; 6 research iterations confirm this; F/P witnesses form infinite branching tree that cannot embed in Int-chain |
| **B: Use CanonicalMCS directly as D** | Blocked | `CanonicalMCS` lacks `AddCommGroup`; parametric infrastructure requires it; TaskFrame requires it |
| **C: Use Int as D but bypass FMCS Int** | Partially viable | The `ParametricCanonicalTaskModel Int` exists (sorry-free); need BFMCS Int with modal saturation; blocked by same F/P coherence issue |
| **D: Find another AddCommGroup D that is "universal"** | Medium | Any D with enough structure could work; needs a sorry-free BFMCS construction; unclear what D would make the construction easier than Int |
| **E: Restructure completeness proof to avoid BFMCS D entirely** | Feasible | Direct construction using CanonicalMCS-indexed truth lemma + specific-D soundness argument (see below) |
| **F: Patch the `≤` vs `<` gap in CanonicalMCS construction** | Feasible | Strengthening `temporal_coherent_family_exists_CanonicalMCS` to use strict inequality might be provable with more work, then embed into larger D |

---

## Recommended Path Forward

### The Correct Architecture: Direct Completeness via Sorry-Free Infrastructure

The key insight from `AlgebraicBaseCompleteness.lean` (lines 36-56) is correct but misses one step:

> "CanonicalMCS does NOT have AddCommGroup, so we cannot directly use it as D. Instead, we use [a D with AddCommGroup] and the CanonicalMCS construction as a template."

The fix: **Use the CanonicalMCS FMCS to construct a BFMCS CanonicalMCS, then observe that the ParametricCanonical machinery is not actually needed for completeness — we just need soundness + a countermodel.**

Here is the mathematically rigorous path:

**Step 1**: Given `¬provable φ`, extend `{¬φ}` to MCS M via Lindenbaum (sorry-free).

**Step 2**: Apply `temporal_coherent_family_exists_CanonicalMCS` to `[¬φ]` to get `fam : FMCS CanonicalMCS` and `root : CanonicalMCS` with `¬φ ∈ fam.mcs root` (sorry-free).

**Step 3**: Build `BFMCS CanonicalMCS` using multi-family modal saturation from `ModalSaturation.lean`. This step requires extending the family set. The modal saturation is sorry-free in ModalSaturation.lean. **This is the remaining construction work.**

**Step 4**: Apply the `CanonicalConstruction.lean` truth lemma (Int-based canonical truth lemma) OR construct an analog for CanonicalMCS. **This is the critical bridge.** `CanonicalConstruction.lean` has `canonical_truth_lemma` for `BFMCS Int`. We need an analog for `BFMCS CanonicalMCS`.

**Step 5**: By truth lemma, `¬φ ∈ fam.mcs root → ¬truth_at ... φ`. Since truth is false at the model, and the model is a valid TaskFrame (with some D), φ is not valid.

**The Critical Gap**: The `parametric_shifted_truth_lemma` in `ParametricTruthLemma.lean` operates on `BFMCS D` for `D : AddCommGroup`. It uses `ParametricCanonicalTaskModel D` which requires `D : AddCommGroup`. To use CanonicalMCS, either:

(a) We need a separate truth lemma for `BFMCS CanonicalMCS` using a specially constructed TaskFrame — but CanonicalMCS-based TaskFrame cannot be built (no AddCommGroup), OR

(b) We observe that `canonical_truth_lemma` in `CanonicalConstruction.lean` already works for `BFMCS Int` and build the proof as: apply `canonical_truth_lemma` but supply a BFMCS Int that is sorry-free.

**Bottom Line for Recommended Path**: The cleanest path is:

1. Build a sorry-free `BFMCS Int` for the BASE completeness proof (without F/P coherence — use a different route)
2. Alternatively, accept that `AlgebraicBaseCompleteness.lean` should use the Int-specific `CanonicalConstruction.lean` truth lemma directly (not the parametric one)

### Alternative Recommended Path: Use Bundle/CanonicalConstruction.lean Directly

`CanonicalConstruction.lean` provides `canonical_truth_lemma` and `shifted_truth_lemma` for `BFMCS Int`. This is the NON-parametric truth lemma. The algebraic base completeness proof in `AlgebraicBaseCompleteness.lean` can instead:

1. Extend `{¬φ}` to MCS M
2. Build `BFMCS Int` containing M — BUT this requires F/P coherence (same obstruction)
3. Apply `shifted_truth_lemma` for BFMCS Int

This hits the same wall. The F/P coherence for ANY `BFMCS D` (with D a linear additive group) requires a dovetailing construction.

### The Real Fix: Use `≤`-Based F/P in CanonicalMCS and Weaken the Truth Lemma

Looking at `TemporalCoherence.lean` line 148-153:
```lean
structure TemporalCoherentFamily (D : Type*) [Preorder D] [Zero D] extends FMCS D where
  forward_F : ∀ t : D, ∀ φ : Formula,
    Formula.some_future φ ∈ mcs t → ∃ s : D, t < s ∧ φ ∈ mcs s
```

And `temporal_coherent_family_exists_CanonicalMCS` gives `≤`, not `<`.

The question is: does the truth lemma NEED strict `<` for F/P, or would `≤` suffice? If `≤` (non-strict) works in the truth lemma, we can use the CanonicalMCS result directly. But with irreflexive semantics, `<` is semantically required.

**This is the true mathematical obstacle**: The semantics uses strict `<` for `F`/`P`, but the CanonicalMCS construction can only prove `≤` (because the witness MCS `s = w` when `CanonicalR w s` — actually this is strict since `CanonicalR` is irreflexive... let me reconsider).

Actually, `CanonicalR w s` is NOT reflexive (it's the accessibility relation, which is strict). So `CanonicalMCS.le_of_canonicalR` gives `w ≤ s` (reflexive closure), and the proof of `forward_F` in `canonicalMCS_forward_F` uses `CanonicalMCS.le_of_canonicalR`. But the FMCS structure's `forward_F` uses `≤` (not strict `<`).

So `temporal_coherent_family_exists_CanonicalMCS` proves `≤`, but `BFMCS.temporally_coherent` needs `<`. This means there's a `≤` vs `<` mismatch in the CanonicalMCS path.

**However**: If `canonical_forward_F` returns `W` with strict `CanonicalR w W` (meaning `w ≠ W`), then we get `w < W` in the preorder (not just `w ≤ W`). The `canonicalMCS_forward_F` proof uses `le_of_canonicalR` which gives `≤`, but if `CanonicalR` implies strict `<`, then the strict version also holds.

From `CanonicalMCS.canonicalR_of_lt`: `w < s` implies `CanonicalR w.world s.world`. The converse (`CanonicalR` implies `<`) holds because `CanonicalR` is irreflexive (by definition: `g_content M ⊆ M'` does NOT include `M = M'` as that would require `G(φ) → φ` to hold universally). So `CanonicalR w s` implies `w ≠ s` (strict), thus `w ≤ s` AND `w ≠ s` gives `w < s`.

This means the `≤` in `temporal_coherent_family_exists_CanonicalMCS` can actually be strengthened to `<` if the theorem is re-proved using `canonicalMCS_forward_F` with the strict version. This would unlock the CanonicalMCS path for `BFMCS.temporally_coherent`.

---

## Impact on Task 987

Task 987 (algebraic base completeness) is the main beneficiary of resolving task 986. Here is the precise impact:

### Current Blocker in AlgebraicBaseCompleteness.lean

```lean
noncomputable def construct_bfmcs_from_mcs
    (M : Set Formula) (h_mcs : SetMaximalConsistent M) :
    Σ' (B : BFMCS D) (h_tc : B.temporally_coherent) ... := by
  sorry  -- Line 155: blocked by F/P coherence
```

This `sorry` blocks `algebraic_base_completeness`.

### The Fix for Task 987

The cleanest path to task 987 completeness (without resolving the Int F/P obstruction) is:

1. **Strengthen `temporal_coherent_family_exists_CanonicalMCS`** to use strict `<` in F/P witnesses (achievable because `CanonicalR` is irreflexive, so witness is strictly greater)

2. **Build `BFMCS CanonicalMCS`** using modal saturation from `ModalSaturation.lean` — the multi-family approach avoids the single-family `modal_backward` sorry

3. **Construct a truth lemma for CanonicalMCS context** — either by:
   - Generalizing `CanonicalConstruction.lean`'s truth lemma to arbitrary `D : Preorder` (not just Int), or
   - Building a separate truth lemma for the specific `CanonicalMCS`-indexed FMCS using `canonicalMCSBFMCS`

4. **For the final step connecting to `valid phi`**: Since validity quantifies over all D, and we need to exhibit a specific D + TaskFrame + model, one option is to use Int as D but construct the TaskModel differently — specifically, using a model where world states are CanonicalMCS elements and time is Int, but with a task relation that doesn't require the CanonicalR chain to have F/P coherence in the Int sense.

**The most pragmatic path**: Directly restructure `algebraic_base_completeness` to use `temporal_coherent_family_exists_CanonicalMCS` (after strengthening to strict `<`) + build a `BFMCS CanonicalMCS` + prove a CanonicalMCS-specific truth lemma + provide the countermodel using an auxiliary embedding into some additive-group-based TaskFrame.

---

## Confidence Level

**High** for the mathematical analysis:
- The `valid` definition was directly read and quantifies over all D
- The `CanonicalMCS` Preorder structure was directly verified (no AddCommGroup)
- The `temporal_coherent_family_exists_CanonicalMCS` signature was directly read
- The `≤` vs `<` mismatch was identified by reading the proof and the structure definition
- The `CanonicalR` irreflexivity argument for upgrading `≤` to `<` is sound (based on reading `CanonicalMCS.canonicalR_of_lt`)

**Medium** for the recommended path's feasibility:
- Step 3 (building `BFMCS CanonicalMCS` via modal saturation) was not fully traced through `ModalSaturation.lean`
- Step 3 (truth lemma for CanonicalMCS) requires additional work not yet in the codebase
- The embedding into an additive-group TaskFrame (Step 4) is architecturally new

**Low** for completing D=Int F/P coherence:
- Six research iterations and Teammate A's analysis both confirm the linearization obstruction
- The recommended path explicitly avoids this

---

## Summary Recommendation

**Do not attempt to complete `intFMCS_forward_F`/`intFMCS_backward_P` (task 986 as stated).** The obstruction is structural.

**For task 987**: The correct path requires:
1. Strengthening `temporal_coherent_family_exists_CanonicalMCS` to prove strict `<` (small proof fix)
2. Building a sorry-free `BFMCS CanonicalMCS` via multi-family modal saturation
3. Proving a CanonicalMCS-specific truth lemma (or generalizing existing one)
4. Providing the countermodel using CanonicalMCS as D via an auxiliary construction

This is substantially less work than the dovetailing construction for D=Int, and it is mathematically sound.
