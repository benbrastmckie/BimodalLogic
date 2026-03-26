# Teammate B Findings: Alternative Cross-Chain Temporal Witness Propagation

**Task**: 58 - Wire Completeness to Frame Conditions
**Focus**: Research alternative mathematical constructions for handling cross-chain temporal witness propagation
**Date**: 2026-03-26

---

## Key Findings

### 1. The Cross-Chain Problem is Real and Currently Blocked by Two Specific Sorries

After reading the codebase, the cross-chain witness propagation problem manifests in exactly two locations in `build_restricted_tc_family` (SuccChainFMCS.lean, lines 3878–3938):

**Sorry 1**: F(psi) in backward chain at position `Int.negSucc k` needs a forward witness
```lean
| Int.negSucc k =>
  -- Backward chain case: F(psi) in backward chain at -(k+1)
  -- For this complex case (F in backward chain needs forward witness), use sorry
  sorry
```

**Sorry 2**: P(psi) in forward chain at position `Int.ofNat (k + 1)` needs a backward witness
```lean
| Int.ofNat (k + 1) =>
  -- Forward chain at positive position k+1
  -- P(psi) in forward chain - need to find witness in earlier position
  -- For this complex case, use sorry
  sorry
```

These two cases represent the fundamental cross-chain challenge: the combined `restricted_succ_chain_fam` is built from two separate Nat-indexed chains meeting at 0, and witnesses for F/P operators can legitimately need to cross the junction.

### 2. The Standard Literature Approach: Single Chain over Z

The standard completeness proof for tense logic over integers (Z) — as documented in Venema's "Temporal Logic" chapter, Burgess's work, and the Gabbay-Hodkinson-Reynolds monograph — does NOT use separate forward and backward chains. Instead, it builds a **single chain enumeration** by interleaving forward and backward extension steps.

The canonical construction for Lin.Z (tense logic on integers) uses a "completeness by construction" technique where:
1. Start with one MCS at position 0
2. At odd stages, extend the chain forward: build MCS at position n+1 from position n
3. At even stages, extend the chain backward: build MCS at position -(m+1) from position -m
4. **Witness obligations** from any position can be satisfied by the extension at a later stage

The critical insight is that F(psi) in backward chain at t=-k can be witnessed at a future forward chain step: when the chain is later extended to position m > 0, the witness for psi is placed there. The unified construction ensures this by including unresolved F/P obligations in a "obligation queue" during construction.

### 3. Why the Current Two-Chain Architecture Blocks Cross-Chain Witnesses

The current `restricted_succ_chain_fam` definition (SuccChainFMCS.lean, line 314):
```lean
noncomputable def succ_chain_fam (M0 : SerialMCS) (n : Int) : Set Formula :=
  match n with
  | Int.ofNat k => forward_chain M0 k
  | Int.negSucc k => backward_chain M0 (k + 1)
```

The two chains are built **independently** from M0. The forward chain extends M0 rightward without knowledge of future backward chain obligations, and vice versa. The chains only "meet" at M0 (index 0) — they are otherwise independent computations.

When F(psi) is in `backward_chain M0 (k+1)` (at position -(k+1)):
- The witness must be at some position m > -(k+1), possibly m > 0
- If m > 0, the witness would need to be in `forward_chain M0 m`
- But `forward_chain` was constructed without knowledge of this F(psi) obligation
- There is no guarantee that `forward_chain M0 m` contains `psi` for any m

**This is a genuine impossibility for the current architecture**: the independent chain construction cannot retroactively guarantee witnesses across the forward/backward junction.

### 4. Additional Sorries Related to the Cross-Chain Problem

Beyond the two main sorry locations, there are subsidiary sorries arising from the same problem:

- `constrained_successor_seed_restricted_consistent` (line 1507): The seed consistency proof fails because boundary_resolution_set elements (which represent "resolve F(psi) by placing psi in the next step") create complications when combining with the restricted predecessor construction
- `neg_not_in_boundary_resolution_set` (line 1412): This helper lemma is not provable in general and blocks the seed consistency proof
- Termination metric sorries in `restricted_bounded_witness` (line 2402–2405) and `restricted_backward_bounded_witness` (line 3822–3824): The termination argument fails because the depth metric is not strictly decreasing in all cases

---

## Alternative Approaches Evaluated

### Approach 1: Joint Construction (Dovetailing)

**Description**: Build both chains simultaneously using a dovetailing/fair-scheduling approach that maintains a global queue of F/P obligations.

**Mathematical Mechanism**:
```
Stage 0: M0 at position 0
Stage 1: Build M1 at position 1 (forward), resolve some F-obligations from M0
Stage 2: Build M_{-1} at position -1 (backward), resolve some P-obligations from M0
Stage 3: Build M2 at position 2 (forward), resolve F-obligations from M_{-1} if needed
Stage 4: Build M_{-2} at position -2, etc.
```

At each forward step k, we include in the construction seed all unresolved F-obligations from ALL previous backward chain elements. This is the key innovation: the forward chain "knows" about backward chain F-obligations.

**Key Technical Requirements**:
1. The obligation queue must be finite at each stage (guaranteed by RestrictedMCS since `closureWithNeg(phi)` is finite)
2. Each obligation must be resolved in finite time (guaranteed by the deferral disjunction ∨ F structure — each step resolves or defers, and deferral decreases the depth within the closure)
3. The construction must maintain DeferralRestrictedMCS at each position

**Lean Formalization Challenges**:
- The inductive definition cannot use simple Nat-recursion on index — it needs a combined pairing argument
- Termination must be proven with respect to the total number of unresolved obligations (which decreases by the bounded-depth argument)
- Well-foundedness of the obligation-resolving recursion requires that each F-obligation eventually resolves (not deferred forever)

**Evidence this works mathematically**: The restricted closure `closureWithNeg(phi)` is finite. Therefore the total number of F/P obligations at any position is bounded by |closureWithNeg(phi)|. The deferral structure guarantees each obligation is resolved within closure_F_bound(phi) steps. So the joint construction terminates with all obligations resolved.

**Confidence**: MEDIUM-HIGH. The mathematical argument is sound, but Lean formalization of a jointly-indexed construction is significantly more complex than the current split architecture.

**Estimated complexity**: HIGH (5-8 hours for a sorry-free Lean proof)

### Approach 2: Closure-Based Seed Enrichment (Pre-compute all witnesses)

**Description**: Instead of building forward and backward chains independently, compute upfront the complete set of cross-chain witness obligations and include them in a modified seed.

**Mathematical Mechanism**:
The seed `M0` (at position 0) is enriched so that:
- For every F(psi) that could appear in any backward chain element: psi is "promised" to appear in the forward chain
- For every P(psi) that could appear in any forward chain element: psi is "promised" to appear in the backward chain

Since the closure is finite, this pre-computation is finite and the enriched seed remains consistent (the witnesses do not contradict M0 since they are just adding new truths consistent with M0).

**Lean Formalization Challenges**:
- The pre-computation requires knowing what F/P obligations will arise in all future chain elements, which requires reasoning about the entire chain before it is built
- This creates a circularity: the chain construction depends on the enriched seed, which depends on the chain

This circularity makes Approach 2 **not viable as stated**. It would require either:
a) A fixed-point argument (build the enriched seed as the least fixed point of an obligation-closure operator), or
b) Restricting to only the F/P obligations visible in M0 itself (which misses obligations arising in later chain elements)

**Confidence**: LOW-MEDIUM for naive version; MEDIUM for fixed-point version

**Estimated complexity**: VERY HIGH (fixed-point argument in Lean is non-trivial)

### Approach 3: Limit-Based / Colimit Approach

**Description**: Define the combined chain as a colimit (direct limit) in the category of Sets (or in a category of MCS structures). The forward chain and backward chain are components in a directed diagram, and their colimit gives a combined model.

**Mathematical Mechanism**:
Mathlib provides `DirectLimit` infrastructure (Mathlib.ModelTheory.DirectLimit). A directed system consists of:
- Objects: MCS at each integer position
- Morphisms: inclusions compatible with the Succ relation

The direct limit of this system would be a model where:
- The index category is (Z, ≤)
- Each "structure" at position n is the MCS at that position
- Maps are inclusions/restrictions respecting formula membership

**Key Insight**: In the direct limit, a formula psi is "eventually true" if it is true at some position and persists forward. This gives a natural semantics for F: F(psi) is true at position t if there exists s > t where psi is true.

**Why this doesn't directly resolve the problem**: The colimit gives a semantic model (a single model where formulas are evaluated) but the cross-chain witness problem is constructive — we need to SHOW that the SPECIFIC forward chain MCS at position m contains psi, not just that psi is "eventually true" in some abstract limit. The truth lemma requires same-family witnesses, not limit-witnesses.

**Confidence**: LOW for solving the specific sorry. The colimit approach gives insights but doesn't eliminate the construction gap.

**Estimated complexity**: VERY HIGH (requires restructuring the entire model around direct limits)

### Approach 4: Fair-Scheduling Single Chain

**Description**: Abandon the split forward/backward architecture entirely. Build a single Int-indexed chain using a dovetailing construction that processes forward and backward extensions alternately.

**Mathematical Mechanism**:
```
Define: chain_world : Int → Set Formula
By recursion on a "stage" function s : Nat → (Int × Set Formula):
  s(0) = (0, M0)
  s(2k+1) = (k+1, succ_of(s(2k).2))    -- forward step
  s(2k+2) = (-(k+1), pred_of(s(2k+1).2)) -- backward step (using M0 as reference)
```

Wait, this still doesn't fix the cross-chain problem because the predecessor at position -(k+1) is built from M0, not from anything in the forward chain.

**Revised version**: Build a SINGLE linear chain by index (k : Nat) → Set Formula using a map:
- index 2k → position k (forward)
- index 2k+1 → position -(k+1) (backward)

Then the chain is: M0, M1, M_{-1}, M2, M_{-2}, M3, M_{-3}, ...

At each step, the successor function sees the CURRENT world and builds the next world with awareness of both forward F-obligations and backward P-obligations visible at the current world.

**Key innovation**: The successor at position m in the physical sequence has access to all obligations accumulated so far. When building M_{-1} (physically at step 2), the constructor sees that M1 (physical step 1) has certain P-obligations, and M_{-1} can be built to satisfy them.

**Lean Technical Requirement**: This requires a fundamentally new chain definition that is NOT simply `forward_chain` and `backward_chain` concatenated. It requires mutual recursion or a combined stage-counting argument.

**Confidence**: MEDIUM. This is the standard approach from the literature (Venema, Burgess) but requires substantial Lean infrastructure changes.

**Estimated complexity**: HIGH (4-6 hours)

### Approach 5: Working Around via the Forward Chain Only

**Description**: Observe that for the SPECIFIC case of restricted completeness, we need:
- F(psi) in backward chain → witness exists at some integer position m (possibly positive)

If we can show that the ENTIRE restricted chain (both forward and backward parts) satisfies F-coherence when looked at from a DIFFERENT starting point...

**Mathematical Observation**: The restricted chain starting from M0 is also a valid chain starting from any of its elements. Consider starting the chain from `backward_chain M0 (k+1)` — then the "forward chain" from this starting point INCLUDES the original forward chain.

**Why this doesn't immediately work**: The `forward_chain` from `backward_chain M0 (k+1)` would not be the same as the original forward chain — it would be a NEW chain built from a different starting MCS.

However, if we could show:
- The forward chain from any RestrictedMCS eventually satisfies F(psi) obligations from within closureWithNeg(phi)

Then we could compose: backward_chain gives us an MCS, forward_chain from THAT MCS gives us F-witnesses.

The resulting "model" would have time structure that interleaves the two chains, not the simple integer ordering — which breaks the model semantics.

**Confidence**: LOW. This approach requires changing the temporal frame structure.

---

## Recommended Approach

**Approach 1 (Joint Construction / Dovetailing)** is the recommended path, with the following concrete strategy for Lean:

### Concrete Implementation Plan

#### Step 1: Define `restricted_joint_chain_at`

```lean
-- Build the chain stage by stage
-- Stage n processes obligation at step n
structure JointChainStage where
  forward_extent : Nat  -- how far forward we've gone
  backward_extent : Nat -- how far backward we've gone
  world : Int → Set Formula  -- the chain so far
  obligations : List Formula  -- unresolved F/P obligations

-- The key: at each stage, we resolve ONE obligation by extending the chain
noncomputable def joint_chain_step (phi : Formula) (s : JointChainStage) : JointChainStage
```

#### Step 2: Prove the Stage Terminates

The termination measure is the number of unresolved obligations: since each step either resolves an obligation directly or defers it with STRICTLY SMALLER F-depth within closureWithNeg(phi), and the closure is finite, the total measure decreases.

#### Step 3: Take the Limit

The final `restricted_succ_chain_fam` is the limit of the joint chain stages, which is well-defined because:
- At each integer position n, the world stabilizes after finitely many stages
- The stabilized world is an MCS

#### Alternative to Step 1-3: Use the `backward_chain` F-obligation route

A simpler implementation: Recognize that F(psi) in `backward_chain M0 (k+1)` means:
- By the SuccChain Succ structure: F(psi) ∈ some world at position -(k+1)
- Since backward_chain MCSs contain deferralDisjunctions: psi ∨ F(psi) ∈ all subsequent worlds
- Eventually one of: psi ∈ some world, or the depth of F-nesting is exhausted
- Since the depth IS bounded (RestrictedMCS), EVENTUALLY psi must appear

The critical observation: if F(psi) ∈ backward_chain at step k, and psi ∉ backward_chain at steps 0..k (which would be "before" in real time, i.e., closer to 0), then by the deferral structure, F(psi) propagates FORWARD. But "forward" from a backward chain position eventually crosses 0 into the forward chain.

**The mathematical argument**: In the restricted setting, F-nesting is bounded. F(psi) being in backward_chain M0 k means that psi has F-depth ≤ max_F_depth_in_closure(phi). By the bounded witness theorem, there exists a finite number of steps to witness psi. These steps, starting from position -(k+1), will land at some position m where m could be positive (in the forward chain).

**The Lean argument**: We need to trace: starting from position -(k+1) in the succ_chain_fam (which has valid Succ relations everywhere), apply `restricted_bounded_witness` with respect to the COMBINED succ_chain_fam rather than just the forward or backward sub-chain.

This requires defining `restricted_bounded_witness_combined` that works for the combined Int-indexed chain.

### Summary Recommendation

The most tractable path is:
1. Define `restricted_combined_bounded_witness` that works over the full `restricted_succ_chain_fam` (the Int-indexed combined chain), not just the sub-chains
2. Use the existing `succ_chain_canonicalTask_forward_MCS_from` infrastructure to chain forward from any Int position
3. Apply the bounded_witness argument to the combined chain, which has valid Succ relations at every junction including across the 0 boundary

The key lemma needed:
```lean
theorem restricted_succ_chain_forward_F (phi : Formula)
    (fam : RestrictedTemporallyCoherentFamily phi)
    (n : Int) (psi : Formula)
    (h_F : Formula.some_future psi ∈ restricted_succ_chain_fam phi fam.seed n) :
    ∃ m : Int, m > n ∧ psi ∈ restricted_succ_chain_fam phi fam.seed m
```

This can be proven by:
1. Getting the F-boundary: ∃ d ≥ 1, iter_F d psi ∈ chain(n) and iter_F (d+1) psi ∉ chain(n)
2. Applying `succ_chain_canonicalTask_forward_MCS_from` for d forward steps from position n
3. Using `bounded_witness` on the resulting CanonicalTask_forward_MCS chain

The boundary step (getting d) requires a combined version of `restricted_forward_chain_F_bounded` that works for Int positions, not just Nat positions.

---

## Confidence Level

**Overall**: MEDIUM

- The mathematical correctness of joint construction is HIGH confidence (it is the standard approach from the literature for tense logic over integers)
- The viability of the "combined bounded witness" shortcut approach is MEDIUM confidence (the Succ infrastructure exists; the question is whether the F-nesting boundary argument extends to Int positions)
- The Lean formalization effort for either approach is HIGH (significant new infrastructure needed)

The recommended immediate action is:
1. Try the "combined bounded witness" shortcut first (lower complexity)
2. Define `restricted_forward_chain_F_bounded_int` that extends F-nesting boundary from Nat to Int positions
3. If this fails, fall back to the full joint construction

---

## References

- `SuccChainFMCS.lean:3878-3938` — The two main sorry locations (build_restricted_tc_family cross-chain cases)
- `SuccChainFMCS.lean:314-320` — Current split forward/backward chain definition
- `SuccChainFMCS.lean:560-577` — `succ_chain_canonicalTask_forward_MCS_from` (existing forward chain infrastructure)
- `SuccChainFMCS.lean:692-737` — `f_nesting_is_bounded_restricted` (key boundedness result)
- `SuccChainFMCS.lean:2402-2405` — Termination sorry in `restricted_bounded_witness`
- `SuccChainFMCS.lean:3822-3824` — Termination sorry in `restricted_backward_bounded_witness`
- Venema, "Temporal Logic" (Chapter 10) — Standard completeness-by-construction technique for Lin.Z
- Burgess (1982), "Axioms for Tense Logic I" — Fair-scheduling witnesses for Since/Until
- Gabbay, Hodkinson, Reynolds, "Temporal Logic: Mathematical Foundations" — Comprehensive treatment of integer tense logic completeness
- Mathlib `DirectLimit.lean` — Colimit infrastructure (alternative approach, not recommended)
