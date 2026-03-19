# Teammate A Findings: Termination Structure Analysis

**Date**: 2026-03-18
**Focus**: Mathematical structure of termination blocker

## Key Findings

### Finding 1: The Recursion Structure Has Two Distinct Regimes

The forward_F proof splits on whether `pair(p.point_index, k) > n` (large step) or not (small step). Only the small step case requires density, and density is the sole source of the termination problem.

In the **large step case**, `witness_at_large_step` directly produces a witness `w` with `phi ∈ w.mcs`. No recursion needed. This case is already proved.

In the **small step case**, density produces `j` such that `encode(iteratedFuture j phi) >= n+1`, and `witness_at_large_step` gives `w` with `iteratedFuture j phi ∈ w.mcs`. If `j > 0`, the recursion restarts: we have `F(iteratedFuture (j-1) phi) ∈ w.mcs` and need to peel off `j` layers.

The termination problem is precisely: **what is the well-founded measure for the small-step case?**

### Finding 2: All Proposed Measures Are Provably Incorrect

Four measures have been proposed and analyzed across reports 26, 27, and the current summaries. Each fails:

**Formula depth (sizeOf phi)**: Density replaces phi with `iteratedFuture j phi`, which is LARGER. Definitively fails.

**Density index j**: After getting `w` with `iteratedFuture j phi ∈ w.mcs`, we are at a NEW point `w` at a higher build stage. The density index `j'` for `w` with formula `iteratedFuture (j-1) phi` is chosen fresh — it depends on `encode(iteratedFuture j' (iteratedFuture (j-1) phi)) >= stage(w) + 1`. The new stage is `pair(p.point_index, k')` which is much larger than `n`. So `j'` could be much larger than `j-1`. This measure does NOT decrease.

**Build stage**: The timeline is infinite and grows without bound. No upper bound exists. Does not decrease toward a bound.

**"Large step propagation" (reports 26 approach D)**: The claim is that after one `witness_at_large_step` at step `m = pair(p.point_index, k)`, the witness `w` has `w.point_index >= m`, ensuring all subsequent calls are large steps. This is **NOT provable** because:
- `w.point_index = (dovetailedBuildState (m-1)).points.length` (by the `pointIndexInvariant`)
- The dovetailed build grows SPARSELY: many steps are no-ops (when the point index is out of range)
- At step `m`, the list length can be arbitrarily smaller than `m`
- Therefore `pair(w.point_index, k'') <= m` is possible, reintroducing small steps

### Finding 3: The Mathematical Termination Argument Is Sound But Infinitary

The recursion terminates mathematically because the timeline IS dense for every formula: for any `w` in the timeline and any `F(chi) ∈ w.mcs`, there exists SOME step in the future where the F-obligation for chi is processed and a witness is added. The timeline construction is complete by construction (by dovetailing all pairs).

However, this termination argument is **not a finite descent**. It relies on:
1. The density of `iteratedFuture i phi` encodings (unbounded growth of encodings)
2. The countability of the timeline (every pair is eventually processed)
3. Transitivity of CanonicalR (allows chaining through intermediate witnesses)

None of these translate directly to a well-founded recursion in Lean because there is no finite bound on the number of density steps needed.

### Finding 4: The Canonical Forward_F Approach Circumvents the Recursion

The key observation: `forward_F_witness_in_timeline` is actually provable WITHOUT the density recursion, using a completely different proof strategy.

**Mathematical argument**:
Given `F(phi) ∈ p.mcs`, the MCS theory (Lindenbaum/extension) guarantees there exists an MCS `W` with `phi ∈ W` and `CanonicalR p.mcs W`. This is a one-step non-constructive argument.

The missing piece is: **is `W` in the dovetailed timeline?**

The answer is YES by the completeness of the dovetailing enumeration, but this requires proving a coverage theorem:

```
dovetailed_covers_all_reachable: Every MCS W that is CanonicalR-reachable from root_mcs
is represented by some point in dovetailedTimelineUnion.
```

**Why this coverage theorem is non-trivially hard to prove**:
The dovetailed construction processes obligation `(p.point_index, encode(phi))` at step `pair(p.point_index, encode(phi))`. For W to appear, we need:
- p's obligation for `phi` to be processed (guaranteed for SOME encoding of phi by density)
- The witness added to be exactly W (it's a FRESH extension, not W in general)

The witness added is `executeForwardStep p.mcs phi` — which produces ONE specific MCS. The canonical forward_F (from Lindenbaum) also gives ONE specific MCS. These need not be equal to the same `W`. The coverage theorem would need to identify WHICH W appears.

This is the same depth of difficulty as the original problem.

### Finding 5: The Fuel-Based Approach Is Mathematically Clean

A fuel-based ("structured recursion with gas") approach sidesteps the termination issue by decoupling existence from the recursion:

**Structure**:
```lean
-- Step 1: Define a computable (but non-terminating) recursive function with a fuel parameter
def forward_F_with_fuel (fuel : Nat) (p : DovetailedPoint) (phi : Formula) : Option (...) := ...
-- Termination: trivially by decreasing fuel

-- Step 2: Prove that for SUFFICIENT fuel, the function always succeeds
-- This proof uses mathematical (non-constructive) reasoning
theorem forward_F_fuel_sufficient (p) (phi) :
    ∃ fuel, (forward_F_with_fuel fuel p phi).isSome = true

-- Step 3: Extract the witness
theorem forward_F_witness_in_timeline (p) (phi) (h_F) :
    ∃ q, ... := by
  obtain ⟨fuel, h_fuel⟩ := forward_F_fuel_sufficient p phi
  exact ... (forward_F_with_fuel fuel p phi) ...
```

Step 1 is trivial. Step 2 is non-constructive but avoids the well-founded recursion problem. Step 3 extracts from Step 2.

**Why Step 2 is provable**: By classical logic, the existence of a sufficient fuel amount follows from the mathematical completeness of the construction. The proof need not be effective.

**Risk**: Step 2 may be hard to prove formally even non-constructively, because it essentially requires the same coverage argument as above.

### Finding 6: The Well-Founded Recursion on a Semantic Measure May Work

Consider this measure for the "small step" case: rather than tracking syntactic properties, track the BUILD STAGE AT WHICH THE GOAL IS ACHIEVED.

Define `min_stage(p, phi) := min { s | ∃ q ∈ dovetailedBuildState(s), CanonicalR p.mcs q.mcs ∧ phi ∈ q.mcs }`.

This exists (by the mathematical completeness of the construction) and is a natural number. For the small-step recursion:
- We have `p` at stage `n`, and apply density to get witness `w` at stage `m = pair(p.point_index, k') > n`
- The new subproblem is: find `q` from `w` at stage `m` with `iteratedFuture (j-1) phi ∈ q.mcs`
- Note: `min_stage(p, phi) <= min_stage(w, iteratedFuture (j-1) phi)` — actually this is NOT guaranteed to decrease

So this semantic measure also fails to provably decrease in Lean without the coverage theorem.

## Summary of the Mathematical Situation

The recursion terminates because:
1. phi is fixed throughout
2. Every MCS has F(neg bot), so density always produces witnesses
3. The timeline is countable and exhausts all (point, formula) pairs

But the Lean proof needs a FINITARY reason it terminates. The core obstacle is:

**The density argument moves us to a higher-indexed formula (larger depth) in exchange for a large-step guarantee. But that guarantee only holds if the witness point_index is large enough — which requires the build to be dense, not sparse.**

The build IS sufficiently dense for the overall construction to work (it processes every pair), but the density of the BUILD (many steps are no-ops) means individual witness `point_index` values can be arbitrarily smaller than their creation step.

## Recommended Approach

### Option 1: Non-Constructive Existence Proof (Cleanest Path)

Prove `forward_F_witness_in_timeline` using classical logic without exhibiting a terminating recursion:

```lean
theorem forward_F_witness_in_timeline (p) (hp) (phi) (h_F) :
    ∃ q ∈ dovetailedTimelineUnion, CanonicalR p.mcs q.mcs ∧ phi ∈ q.mcs := by
  -- By classical logic, either such a q exists or it doesn't
  -- The construction guarantees it exists (by dovetailing completeness)
  -- Formalize via: there exists a stage s where the obligation pair(p.point_index, k) is processed
  -- and the witness is added. The witness is at that stage.
  by_contra h_none
  push_neg at h_none
  -- Derive contradiction: p.mcs is maximal consistent with F(phi), so phi must be satisfiable
  -- The obligation for phi at p is processed at step pair(p.point_index, encode(phi))
  -- At that step, a witness is added (by witness_at_large_step for sufficient density)
  -- This contradicts h_none
  sorry
```

The sorry here is a CLEAN sorry: it documents exactly what needs to be proven, and the mathematical argument is clear. The `by_contra` + contradiction approach may be more tractable than direct construction.

### Option 2: Direct Invocation of witness_at_large_step at the Right Scale

Rather than recursion, use the density argument ONCE with a large enough iteration count, and observe that `witness_at_large_step` gives phi (not F^j(phi)) as the direct formula at the right encoding.

**Key observation**: `witness_at_large_step p n hp phi h_F k h_dec h_large` gives a witness `w` with **phi** (not some iterated version) in `w.mcs`. The density argument was about finding the RIGHT encoding k such that `pair(p.point_index, k) > n`. Once we have the right k for phi, we call `witness_at_large_step` ONCE and get phi directly.

**What this means**: The recursion in `forward_F_chain_witness` is UNNECESSARY! The structure `forward_F_core` already does this correctly for the large step case. The recursion only arises because we have `F^(i+1)(phi) ∈ p.mcs` rather than `F(phi) ∈ p.mcs`.

**The real problem**: `forward_F_witness_in_timeline` only needs `F(phi) ∈ p.mcs`, not `F^(i+1)(phi) ∈ p.mcs`. So `forward_F_chain_witness` (with `i` parameter) is an unnecessary generalization that introduces the recursion.

**Proposed clean fix**: Remove `forward_F_chain_witness` entirely and prove `forward_F_witness_in_timeline` directly without the `i`-parameterization. The proof splits on large/small step exactly as `forward_F_core` does, and in the small step case, uses density to get a LARGE encoding k' such that `witness_at_large_step` is directly applicable with the original phi.

Wait — but `witness_at_large_step` requires `decodeFormulaStaged k = some phi` with k such that `pair(p.point_index, k) > n`. In the small step case, `pair(p.point_index, encode(phi)) <= n`. So we need a DIFFERENT encoding of phi... but phi has a UNIQUE encoding.

This is the fundamental obstacle: phi has a unique Lean encoding, so we cannot use density on phi's encoding directly. Density gives us `iteratedFuture j phi` which has a larger encoding, but then we have `iteratedFuture j phi` in the witness, not phi.

### Option 3: Accept the sorry with Documentation (Current Best)

The mathematical content is correct: the construction is complete and every F-formula is witnessed. The sorry at lines 806, 959, 1028 accurately reflects a Lean formalization gap, not a mathematical gap.

The clearest documentation is:
```lean
-- MATHEMATICAL GAP: This theorem is mathematically true but requires a
-- termination argument that goes beyond simple structural induction.
-- The density construction ensures every F-formula obligation is eventually
-- processed, but expressing this as a well-founded recursion in Lean requires
-- either: (a) a build density invariant (provably false for sparse builds),
-- (b) a semantic measure requiring the coverage theorem, or
-- (c) a fuel-based approach with a non-constructive sufficiency proof.
-- All three require significant additional infrastructure.
sorry
```

## Confidence Level

**High** for the analysis of WHY termination fails. All proposed approaches in reports 26-27 have been checked and the failure modes are clearly identified.

**Medium** for the recommended path forward. Option 2 ("remove the i-parameterization") is the most promising direction that has NOT been fully explored in prior reports. It deserves implementation attempt first. The key question is whether `forward_F_witness_in_timeline` can be proved directly without the chain witness structure.

**Low** for any specific proof completing without sorry. The mathematical gap is real and the formalization infrastructure to bridge it does not currently exist in the codebase.

## Specific Code Insight

In `forward_F_core` (line 652), the proof structure is:
1. Get encoding `k` of `psi`
2. If `pair(p.point_index, k) > n`: `witness_at_large_step` gives `psi` directly
3. If small step: use density to get large `k'` with `encode(iteratedFuture j psi) = k'`, then `witness_at_large_step` gives `iteratedFuture j psi` in `w.mcs`
4. For `j = 0`: done. For `j > 0`: sorry (line 806)

The sorry at line 806 is THE ONLY blocker. Everything else is proved. The question is whether there's a path from "F(iteratedFuture j' psi) ∈ w.mcs" to "psi ∈ q.mcs for some q reachable from w."

This IS provable by `forward_F_core` applied recursively to `w` with formula `iteratedFuture j' psi`... but ONLY IF `forward_F_core` terminates. This is the circular dependency.

The cleanest resolution: define `forward_F_core` as a `WellFounded.fix` with measure `(stage_of_witness, j)` in lexicographic order where stage_of_witness is the minimal build stage containing the point. But this requires proving the stage of `w` is strictly larger than the stage of `p`, and that `j` decreases once the stage is fixed. The stage increase is clear (p is at stage n, w is at stage pair(p.idx, k') > n), but the j-decrease across different stages is not.
