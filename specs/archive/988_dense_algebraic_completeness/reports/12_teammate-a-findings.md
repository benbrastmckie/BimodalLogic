# Research Report: Task #988 - Teammate A Findings

**Task**: dense_algebraic_completeness
**Date**: 2026-03-19
**Focus**: Implementation approaches and Boneyard resources (forward_F chain witness)

## Key Findings

### 1. The Exact Blocker in forward_F_chain_witness

The Boneyard file `Theories/Bimodal/Boneyard/Task994_DovetailedQuot/DovetailedTimelineQuot.lean` contains the full documentation of the blocker. The proof structure is:

```
forward_F_chain_witness i p hp phi h_F_iter:
  "If F^(i+1)(phi) ∈ p.mcs, then ∃ q in timeline with CanonicalR p.mcs q.mcs and phi ∈ q.mcs"
```

Proof by strong induction on `i`. At line 932-959, the proof splits on `j` (the density index chosen to make `encode(iteratedFuture j (iteratedFuture i phi)) >= n+1`):

- **j = 0 case** (lines 933-949): PROVEN. When density index is 0, the witness has `iteratedFuture i phi ∈ w.mcs`. For `i = 0` this gives `phi` directly; for `i = i' + 1` the induction hypothesis `ih i' < i` applies and the proof chains through `canonicalR_transitive`.
- **j = j' + 1 case** (lines 950-959): SORRY. When density index is `j' + 1 > 0`, the witness `w` has `iteratedFuture (j'+1+i) phi ∈ w.mcs`. The induction hypothesis requires `j'+1+i - 1 = j'+i < i`, which fails when `j' >= 0` since `j' + i >= i`.

The analogous sorry exists in `backward_P_chain_witness` at line 1028.

Additionally, `forward_F_core` at line 806 has a sorry for the same reason: when the density index `j > 0` is chosen in the small-step case, the recursion cannot be shown to terminate by formula size or stage alone.

### 2. Why the j > 0 Case Is Hard

The density argument works as follows:
1. Given `F(phi) ∈ p.mcs` and `p` at stage `n`
2. Choose `j` so `encode(iteratedFuture j (iteratedFuture i phi)) >= n + 1`
3. Use `density_iterate_in_mcs` to get `F(iteratedFuture j (iteratedFuture i phi)) ∈ p.mcs`
4. Apply `witness_at_large_step` to get witness `w` with `iteratedFuture (j+i) phi ∈ w.mcs`

When `j > 0`, `iteratedFuture (j+i) phi = F(iteratedFuture (j+i-1) phi)`. This is a DEEPER formula than the original target. The intended recursion would be:
- From `F(iteratedFuture (j+i-1) phi) ∈ w.mcs`, recursively apply `forward_F_chain_witness` with index `j+i-1`
- But `j+i-1 >= i` when `j >= 1`, so the strong induction hypothesis does not apply

The comments in the file (lines 709-756, 903-931) show extensive analysis of the termination problem. The author correctly identifies that:
- Stage number increases (the witness `w` is at stage `> n`), but this alone is not a well-founded measure for Lean's kernel
- Formula depth can increase (from `phi` to `iteratedFuture (j+i-1) phi`)
- There is no obvious lexicographic order that provably decreases

### 3. Well-Founded Recursion Feasibility Analysis

The comments in the file propose a lexicographic measure `(build_stage, formula_depth)` where build_stage is the stage of the current point `p`. The argument would be:

- Each call to `witness_at_large_step` gets a witness `w` at stage `Nat.pair p.point_index k' > n`
- So `build_stage` strictly increases
- The formula `iteratedFuture (j+i-1) phi` has depth `j+i-1+sizeOf(phi)`, which may be larger than before
- However, `build_stage` dominates in the lexicographic order

**Why this is hard to formalize**: Lean's well-founded recursion requires a structurally decreasing argument, or an explicit well-founded relation. The "stage of the current point" is not easily extracted as a natural number for a Lean `decreasing_by` clause. The `DovetailedPoint` type stores `point_index` but the stage of creation is implicit (computed via `dovetailedBuildState`). Extracting a stage number would require:
1. Proving that `p.point_index` monotonically relates to the stage when `p` was introduced
2. Showing the stage of `w` (which is `Nat.pair p.point_index k'`) strictly exceeds the stage of `p`

Step 2 follows from `h_large : Nat.pair p.point_index k' > n` where `n` is `p`'s stage. Step 1 requires proving the pointIndexInvariant gives an injective mapping of stages to point indices, which is available via `dovetailedBuildState_pointIndexInvariant` but connecting this to a Lean termination measure would require significant infrastructure.

### 4. DovetailedCoverage Witnesses vs TimelineQuot MCS Sets

This is the FUNDAMENTAL ARCHITECTURAL GAP identified in plan v10 and confirmed by examination:

**DovetailedCoverage provides**:
- `dovetailedTimeline_has_future`: For any `p ∈ dovetailedTimelineUnion`, ∃ `q ∈ dovetailedTimelineUnion` with `CanonicalR p.mcs q.mcs` (no phi-membership constraint)
- `witness_at_large_step`: For `F(phi) ∈ p.mcs` with appropriate encoding condition, gives `q` with `CanonicalR p.mcs q.mcs AND phi ∈ q.mcs` (phi-specific witness, but only under large-step condition)

**TimelineQuot requires** (for `timelineQuot_forward_F`):
- For any `t : TimelineQuot` with `F(phi) ∈ timelineQuotMCS(t)`, find `t' > t` with `phi ∈ timelineQuotMCS(t')`

The gap: `witness_at_large_step` requires `Nat.pair p.point_index k > n` where `k` encodes `phi`. For a point `p` at stage `n`, this holds if `encode(phi) > n - p.point_index`. But for formulas with small encodings processed at late stages, the encoding may NOT be large enough, requiring density iteration, which introduces the `j > 0` problem.

`dovetailedTimeline_has_future` only provides `CanonicalR` (no `phi` guarantee), making it insufficient for `forward_F`.

**The connection**: The proof `forward_F_chain_witness` was specifically designed to bridge this gap by using density to boost the encoding. The `j = 0` case works perfectly. Only `j > 0` is broken.

### 5. Assessment of the Boneyard Approach

The Boneyard file is NOT dead code in the mathematical sense - the proof strategy is mathematically sound. The `j = 0` case is completely proven and illustrates the approach. The `j > 0` case requires either:
- Mutual recursion (two mutually recursive functions: one for the `j = 0` case and one for the `j > 0` case)
- Explicit well-founded recursion on stage number
- A lemma that avoids density-index blowup entirely

The Boneyard README (written during Task 994 archival) confirms: "All sorries in these files trace to the same fundamental issue: proving that density witnesses from `density_frame_condition` are contained in the dovetailed timeline union." This is accurate for the DenselyOrdered sorry at line 295, but slightly mis-states the chain-witness sorry: the chain-witness sorries are about TERMINATION of a well-founded recursion, not about density_frame_condition witnesses per se.

## Recommended Approach

### Option 1: Complete well-founded recursion via stage number (HIGH EFFORT, CLEANEST)

Define a termination measure using `p.point_index` as a proxy for stage:
- Establish that `witness_at_large_step` gives `w` with `w.point_index > p.point_index`
- Use `p.point_index` as the termination measure in `forward_F_core`
- This requires proving: "the witness produced by `witness_at_large_step` has point_index strictly greater than the source point"

Looking at `DovetailedBuild.lean`, points are added sequentially, so `point_index` IS monotone with stage. The witness `w` is added at stage `Nat.pair p.point_index k'` and assigned index proportional to that stage. If we can prove `w.point_index >= Nat.pair p.point_index k' > p.point_index` (for reasonable `k'`), then `p.point_index` is a valid termination measure.

This approach would work for `forward_F_core` (which has explicit `p` parameter). The key lemma needed:
```lean
theorem witness_point_index_larger (p n hp phi h_F k h_dec h_large) :
    let w := (witness_at_large_step ...).choose
    p.point_index < w.point_index
```

### Option 2: Strengthen the induction hypothesis (MEDIUM EFFORT)

Instead of inducting on `i` (the iteration depth), reformulate with a joint induction that includes the stage:
```lean
-- Induct on (Nat.pair stage formula_size) lexicographically
-- Each step either decreases stage-gap OR formula-size at same stage-gap
```

This requires reformulating `forward_F_chain_witness` with an explicit stage parameter.

### Option 3: Bypass the chain witness entirely using a direct DovetailedBuild argument (MEDIUM EFFORT, MOST PRAGMATIC)

The Boneyard approach builds `forward_F` from first principles using the dovetailed structure. The active code path in `CanonicalEmbedding.lean` needs `ratFMCS_forward_F`, which needs `timelineQuot_forward_F`. Rather than fixing the Boneyard chain-witness proofs, build `timelineQuot_forward_F` DIRECTLY from `DovetailedCoverage`:

Key observation: `witness_at_large_step` already gives phi-specific witnesses when the large-step condition holds. For `timelineQuot_forward_F`, we can use a two-step argument:
1. Given `F(phi) ∈ timelineQuotMCS(t)` at representative point `p` at stage `n`
2. Apply density to get `F(iteratedFuture j phi) ∈ p.mcs` for sufficiently large encoding index
3. Apply `witness_at_large_step` directly for `iteratedFuture j phi` to get witness `w` with `iteratedFuture j phi ∈ w.mcs` at stage > n
4. This gives `t' > t` with something in `timelineQuotMCS(t')`

But this only proves the existence of SOME witness formula in `t'`, not that `phi ∈ t'`. This remains the fundamental obstacle.

**The truly clean fix**: Use `witness_at_large_step` directly for `phi` without density iteration. This requires showing `Nat.pair p.point_index (encode phi) > n`. This is true IF `encode(phi) > n - p.point_index`. When this fails (small-stage problem), use density to find `j` with `encode(F^j phi) > n`, then observe that `F^j phi = iteratedFuture j phi` being in `w.mcs` means `phi` can be extracted by `j` further steps of `forward_F`. This is exactly the chain-witness proof, and recursion is bounded by `j` (which decreases each time we have a formula with `j` fewer iterations). The REAL termination argument is on `j`, not on stage.

### Option 4: Reformulate as termination on j directly with an explicit witness (RECOMMENDED)

The current `forward_F_chain_witness` attempts to use strong induction on `i` but gets stuck when `j > 0` because `j+i > i`. The key insight from careful re-reading:

When `j > 0`, we have `iteratedFuture (j+i) phi ∈ w.mcs`. This is:
- `F(iteratedFuture (j+i-1) phi) ∈ w.mcs`

We can apply the chain witness recursively to `w` with index `j+i-1`. The CRUCIAL point missed: this is NOT circular. We need the function to terminate. Consider the TOTAL depth `j + i` in `w`:
- The strong induction was on `i` but should be on `j + i` (the total remaining depth)
- In the recursive call: new index = `j + i - 1`
- `j + i - 1 < j + i` (decreases by exactly 1!)
- New `p` is `w`, new formula depth argument is `j + i - 1`

This gives a well-founded proof if we reformulate as:
```lean
theorem forward_F_chain_witness_total (total : Nat) (p : DovetailedPoint)
    (hp : p ∈ dovetailedTimelineUnion ...) (phi : Formula)
    (h_iter : iteratedFuture (total + 1) phi ∈ p.mcs) :
    ∃ q in timeline, CanonicalR p.mcs q.mcs ∧ phi ∈ q.mcs
```
Inducting on `total`. In the `j = 0, i = total` case, the existing proof works. In the `j > 0` case with any `i`, the recursive call uses `j + i - 1 < j + i = total`, which satisfies the strong induction.

**This Option 4 appears to be the correct fix.**

## Evidence/Examples

### The Fully-Proven j = 0 case (lines 933-949)

```lean
| zero =>
  -- j = 0: iteratedFuture i phi ∈ w.mcs
  simp only [Nat.zero_add] at hw_phi h_combine
  cases i with
  | zero =>
    -- i = 0: phi ∈ w.mcs directly
    simp only [iteratedFuture] at hw_phi
    exact ⟨w, h_w_in_union, hw_R, hw_phi⟩
  | succ i' =>
    -- i = i' + 1: F(iteratedFuture i' phi) ∈ w.mcs, apply ih with m = i' < i
    simp only [iteratedFuture] at hw_phi
    have h_ih := ih i' (Nat.lt_succ_self i') w h_w_in_union hw_phi
    obtain ⟨q, hq_mem, hq_R, hq_phi⟩ := h_ih
    have h_trans := canonicalR_transitive p.mcs w.mcs q.mcs p.is_mcs hw_R hq_R
    exact ⟨q, hq_mem, h_trans, hq_phi⟩
```

### The Broken j > 0 case (lines 950-959)

```lean
| succ j' =>
  -- j = j' + 1 > 0: need more sophisticated argument
  -- The formula in w.mcs is F^(j'+1+i)(phi), which has depth j'+1+i from phi
  -- This is MORE than i, so ih doesn't apply directly
  sorry
```

### Key invariant from witness_at_large_step (DovetailedCoverage.lean line 231-268)

`witness_at_large_step` requires `Nat.pair p.point_index k > n` where `n` is `p`'s stage. This is the large-step condition. When `k = encode(phi)` and `encode(phi) <= n - p.point_index`, the condition fails, requiring density iteration (choosing `j > 0`).

### The DovetailedTimelineQuot sorry at line 295 (density intermediate)

Separate from the chain-witness issue. This sorry is about showing that `density_frame_condition` intermediates appear in the dovetailed timeline union. The Boneyard README correctly identifies this as an "enumeration completeness" gap: the dovetailed enumeration processes F/P formulas, not density intermediates directly.

## Confidence Level

**High** for the analysis of the blocker and why it exists.

**High** for Option 4 (reformulate as total-depth induction) as the correct mathematical fix.

**Medium** for Option 4 implementation difficulty - it requires restructuring the current proof but the mathematical content is sound. The induction on `total = j + i` where `j` is chosen by density is the key.

**Low** that the Boneyard approach (DovetailedTimelineQuot path) should be the primary route for Task 988 completion. The active codebase uses the TimelineQuot path (DenseTimeline -> TimelineQuot -> CantorApplication), and the main sorry is in `TimelineQuotCompleteness.timelineQuot_not_valid_of_neg_consistent`. The chain-witness sorries in the Boneyard only matter if the Boneyard approach is restored as the primary path.

## Implications for Plan v10

Plan v10 Phase 1 is blocked because it needs `timelineQuot_forward_F`. This theorem requires: for `F(phi) ∈ timelineQuotMCS(t)`, find `t' > t` with `phi ∈ timelineQuotMCS(t')`. The DenseTimeline / TimelineQuot construction is based on the staged build which does NOT guarantee phi-specific witnesses (only CanonicalR-reachability). The DovetailedCoverage witnesses DO provide phi-specific witnesses via `witness_at_large_step`, but they live in the DovetailedBuild, not in the DenseTimeline.

**The architectural bridge needed**: Show that the DenseTimeline (or its quotient, TimelineQuot) contains phi-specific witnesses when `F(phi) ∈` some MCS in the timeline. This is equivalent to proving `timelineQuot_forward_F`, which is the root blocker.

The chain-witness proof in the Boneyard is the SAME mathematical content as what is needed for `timelineQuot_forward_F`, just expressed over DovetailedBuild rather than DenseTimeline/TimelineQuot. Fixing the Boneyard chain-witness (Option 4 above) would give the mathematical content needed, but would then need to be lifted to the TimelineQuot setting.

**Alternative direction**: Prove `timelineQuot_forward_F` directly using the DovetailedBuild by showing that every TimelineQuot element corresponds to a DovetailedBuild element, and use `witness_at_large_step` directly. This avoids the chain-witness proof entirely.
