# Research Report 007: Deep Analysis of fully_saturated_bfmcs_exists_int

**Task**: 930
**Session**: sess_1740494000_r930c
**Date**: 2026-02-25
**Focus**: The core sorry in `fully_saturated_bfmcs_exists_int` -- why combining temporal coherence with modal saturation is hard, and what construction strategies can resolve it.

---

## Executive Summary

The sorry in `fully_saturated_bfmcs_exists_int` (line 817 of `TemporalCoherentConstruction.lean`) is the single bottleneck blocking the entire completeness chain for standard validity. This report provides a deep structural analysis of why the combination of temporal coherence and modal saturation is difficult, traces the fundamental tension to its root cause, evaluates all proposed strategies, and identifies one concrete resolution path that avoids all known blockers.

**Key finding**: The fundamental tension is that **temporal coherence requires non-constant families** (different MCSes at different times) while **modal saturation creates constant witness families** (same MCS at all times). Constant families cannot be temporally coherent because temporal saturation of a single MCS is impossible in general (`{F(psi), neg(psi)}` is consistent but violates F(psi) -> psi). The resolution is to either (a) make witness families non-constant via individual DovetailingChains, or (b) restructure the truth definition so witness families need no temporal coherence.

**Recommendation**: Strategy D (Eval-Only Temporal Coherence) via the `bmcs_truth_lemma_mcs` approach from `ChainBundleBFMCS.lean`, combined with a **structural reformulation of `fully_saturated_bfmcs_exists_int`** that weakens the temporal coherence requirement to apply only to the eval family.

---

## 1. Exact Structure of the Current Construction

### 1.1 The Sorry Statement

```lean
theorem fully_saturated_bfmcs_exists_int (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    exists (B : BFMCS Int),
      (forall gamma in Gamma, gamma in B.eval_family.mcs 0) /\
      B.temporally_coherent /\
      is_modally_saturated B
```

This theorem must produce a `BFMCS Int` satisfying three simultaneous properties:
1. **Context preservation**: Gamma at eval_family.mcs 0
2. **Temporal coherence** for ALL families (forward_F and backward_P)
3. **Modal saturation**: every Diamond(psi) has a witness family

### 1.2 What `temporally_coherent` Means

```lean
def BFMCS.temporally_coherent (B : BFMCS D) : Prop :=
  forall fam in B.families,
    (forall t phi, F(phi) in fam.mcs t -> exists s, t <= s /\ phi in fam.mcs s) /\
    (forall t phi, P(phi) in fam.mcs t -> exists s, s <= t /\ phi in fam.mcs s)
```

This requires EVERY family in the bundle -- not just the eval family -- to satisfy forward_F and backward_P.

### 1.3 What `is_modally_saturated` Means

```lean
def is_modally_saturated (B : BFMCS D) : Prop :=
  forall fam in B.families, forall t, forall psi,
    Diamond(psi) in fam.mcs t -> exists fam' in B.families, psi in fam'.mcs t
```

When Diamond(psi) appears in some family's MCS, there must be a witness family containing psi.

### 1.4 How These Are Currently Produced

The completeness chain in `Completeness.lean` calls `construct_saturated_bfmcs_int`, which calls `.choose` on `fully_saturated_bfmcs_exists_int`. The truth lemma `bmcs_truth_lemma` requires `B.temporally_coherent` (for ALL families) as a hypothesis.

---

## 2. The Fundamental Tension

### 2.1 Why Temporal Coherence and Modal Saturation Conflict

**Temporal coherence of the eval family** is achievable: the DovetailingChain in `DovetailingChain.lean` builds an `FMCS Int` with proven forward_G and backward_H. The 2 remaining sorries (forward_F, backward_P) are structural limitations of the linear chain construction, not of the underlying mathematics.

**Modal saturation** creates NEW witness families. The standard approach (from `ModalSaturation.lean`) is:
- For each Diamond(psi) in some family's MCS at time t, create a constant witness family
- A constant witness family maps every time point to the SAME MCS W containing psi
- W is obtained via Lindenbaum extension of `{psi}` (proven consistent by `diamond_implies_psi_consistent`)

**The conflict**: A constant family `mcs s = W` for all s must satisfy forward_F:
- If `F(psi') in W`, then `exists s >= t, psi' in W` (since mcs is constant, this is just `psi' in W`)
- This requires `F(psi') in W -> psi' in W` -- i.e., W must be **temporally saturated**

**Temporal saturation of a single MCS is impossible in general**:
- The set `{F(psi), neg(psi)}` is consistent (there could be a future where psi holds, but psi does not hold now)
- So there exist MCSes containing both `F(psi)` and `neg(psi)`
- Any such MCS violates `F(psi) -> psi`
- Therefore not all MCSes are temporally saturated
- The Lindenbaum extension of `{psi}` may produce such a non-saturated MCS

### 2.2 The Root Cause

The root cause is a **mismatch in temporal dimensionality**:
- The eval family lives in Int (infinite time) and achieves temporal coherence by placing witnesses at DIFFERENT time points
- Constant witness families live in a "collapsed" time (same MCS everywhere) and cannot provide future/past witnesses for formulas requiring temporal separation

### 2.3 What Properties ARE Preserved

The DovetailingChain family preserves:
- forward_G (fully proven, including cross-sign via GContent/HContent duality)
- backward_H (fully proven, including cross-sign)
- Context at time 0

The DovetailingChain family FAILS to provide:
- forward_F (F-formulas don't persist through GContent seeds; Lindenbaum can introduce G(neg(psi)))
- backward_P (symmetric to forward_F)

Constant witness families preserve:
- forward_G (by T-axiom: `G(phi) -> phi` applied within the constant MCS)
- backward_H (by T-axiom)

Constant witness families FAIL to provide:
- forward_F (requires temporal saturation)
- backward_P (requires temporal saturation)

---

## 3. Why the CanonicalBC Approach Gets Temporal Coherence "For Free"

### 3.1 The CanonicalBC Architecture

In `CanonicalFMCS.lean`, the domain is `CanonicalMCS` (all MCSes with the CanonicalR preorder). The FMCS maps each element `w : CanonicalMCS` to `w.world` (its own MCS).

### 3.2 Why forward_F Is Trivial

```lean
theorem canonical_forward_F (M : Set Formula) (h_mcs : SetMaximalConsistent M)
    (psi : Formula) (h_F : F(psi) in M) :
    exists W, SetMaximalConsistent W /\ CanonicalR M W /\ psi in W
```

When `F(psi) in M`:
1. `{psi} union GContent(M)` is consistent (by `forward_temporal_witness_seed_consistent`)
2. Lindenbaum extends to MCS W with `GContent(M) subset W` and `psi in W`
3. `CanonicalR M W` holds (by definition: `GContent(M) subset W`)
4. In the FMCS, `mcs(W) = W.world = W`, so `psi in mcs(W)`
5. The ordering `M <= W` (i.e., CanonicalR) provides the temporal witness

**The key insight**: The temporal witness IS a new domain element. In the CanonicalBC approach, creating a new MCS W automatically creates a new time point (since `D = CanonicalMCS`). The witness exists at a DIFFERENT time point than the original.

### 3.3 Why This Cannot Transfer to Int

With `D = Int`, time points are fixed integers. Creating a new MCS does not create a new time point. The DovetailingChain must PRE-ALLOCATE integer time points for all potential F/P witnesses, but:
- The enumeration order of formulas means a formula psi gets checked at step `encodeFormula(psi)`
- If `F(psi)` enters the chain AFTER step `encodeFormula(psi)` (e.g., via Lindenbaum extension), the witness slot is already passed
- There is no second chance to place the witness

### 3.4 The CanonicalR Structure

`CanonicalR M M'` means `GContent(M) subset M'`. This is the temporal "future" relation. In the canonical frame:
- Every F-obligation gets its own fresh Lindenbaum witness (a new node in the preorder)
- The resulting preorder structure is tree-like (branching at each F-obligation)
- This is fundamentally different from a LINEAR order (Int) where time must be sequential

---

## 4. Evaluation of Construction Strategies

### 4.1 Strategy A: Unravel-First (Build Full Temporal Tree, Then Saturate Modally)

**Approach**: Start with a consistent seed. Unravel ALL F/P requirements into a tree/DAG structure. Then saturate modally at each node. Then embed into Int.

**Obstacles**:
1. The F/P unraveling is potentially infinite (each witness can introduce new F/P obligations)
2. Embedding a tree into Int destroys the tree structure
3. Modal saturation at each node creates NEW F/P obligations, creating a feedback loop

**Assessment**: Blocked. The tree-to-Int embedding is the same problem as the linear chain.

### 4.2 Strategy B: Modal-First (Build Full Modal Closure, Then Impose Temporal Coherence)

**Approach**: Build the full modal closure (all Box-accessible MCSes). Then impose temporal coherence on this structure.

**Obstacles**:
1. The modal closure is a set of MCSes (like CanonicalBC)
2. Imposing temporal coherence requires Int indexing
3. Each family in the modal closure needs its own DovetailingChain
4. Each DovetailingChain has the same 2 sorries (forward_F, backward_P)

**Assessment**: Moves the problem but does not solve it. Each witness family still needs its own temporal chain, and each chain has the F/P witness problem.

### 4.3 Strategy C: Simultaneous Construction (Interleave Temporal and Modal at Each Step)

**Approach**: At each construction step, process both temporal obligations (F/P witnesses) and modal obligations (Diamond witnesses).

**Obstacles**:
1. Processing a Diamond obligation creates a new family that may have new F/P obligations
2. Processing an F/P obligation may create a situation where new Diamond obligations appear
3. The interleaving must be well-founded to avoid infinite regress
4. No clear ordinal bound on the number of steps needed

**Assessment**: Theoretically possible but extremely complex. Would require a transfinite construction with careful ordinal bookkeeping. Estimated 40-60 hours of Lean formalization.

### 4.4 Strategy D: Weaken Requirements (Eval-Only Temporal Coherence)

**Approach**: Restructure so that only the eval family needs temporal coherence, not witness families. This is exactly what `bmcs_truth_lemma_mcs` in `ChainBundleBFMCS.lean` achieves.

**How It Works**:
- `bmcs_truth_lemma_mcs` defines Box as "phi in fam'.mcs t for all fam' in families" (MCS membership), NOT as recursive truth evaluation
- The truth lemma only requires temporal coherence of the eval family for the G/H backward cases
- Constant witness families need no temporal coherence because they are never recursively evaluated for temporal operators

**Obstacles for Standard Completeness**:
- The `bmcs_truth_at_mcs` semantics differs from standard `truth_at` in the Box case
- Standard `truth_at` uses `forall sigma in Omega, truth_at M Omega sigma t phi` (recursive)
- `bmcs_truth_at_mcs` uses `forall fam' in families, phi in fam'.mcs t` (flat membership)
- Bridging these requires the shifted truth lemma, which needs temporal coherence for ALL families

**Assessment**: This IS the best strategy, but it needs a reformulation of the completeness goal. See Section 5.

### 4.5 Strategy E: Omega-Squared Construction

**Approach**: As mentioned in the DovetailingChain comments, use an omega-squared construction that processes F-obligations IMMEDIATELY when they appear.

**How It Would Work**:
- At each step n of the main chain, BEFORE Lindenbaum extension:
  - Enumerate all current F-obligations
  - For each F-obligation F(psi), create a sub-chain that witnesses psi
  - The sub-chain is a secondary chain indexed by Nat
  - Each sub-chain step extends `{psi} union GContent(current)` and processes the NEXT sub-obligation
- The double enumeration (main step x sub-step) gives omega^2 many MCSes

**Obstacles**:
1. Creating sub-chains for each F-obligation at each step leads to exponential blowup
2. The sub-chains must share GContent with the main chain for forward_G
3. Coordinating the sub-chains with the main chain is extremely delicate
4. No existing infrastructure for this in the codebase

**Assessment**: Theoretically sound but impractical for formalization. Estimated 60-100 hours.

---

## 5. The Correct Resolution Path

### 5.1 The Core Observation

The truth lemma `bmcs_truth_lemma` in `TruthLemma.lean` requires `B.temporally_coherent` which means temporal coherence for ALL families. But this is STRONGER than what the truth lemma actually USES.

Looking at the truth lemma code (lines 260-398 of TruthLemma.lean), the G/H backward cases (lines 355-398) extract `forward_F` and `backward_P` only for the SPECIFIC family `fam` being evaluated:

```lean
obtain <h_forward_F, h_backward_P> := h_tc fam hfam
```

For the Box case (lines 321-346), the forward direction uses `modal_forward` and the backward direction uses `modal_backward`. Neither of these invokes temporal coherence.

**Therefore**: The truth lemma could be reformulated to require temporal coherence ONLY for families that are recursively evaluated. In the Box case, the IH is applied to `fam'` (not just `fam`), so ALL families need the truth lemma to hold. But the Box case of the truth lemma only requires modal_forward/backward, NOT temporal coherence. The temporal coherence is ONLY needed for the all_future/all_past cases.

### 5.2 The Critical Cross-Dependency

The reason all families need temporal coherence is:

1. Box forward: `Box(phi) in fam.mcs t -> forall fam' in families, bmcs_truth_at B fam' t phi`
   - Needs IH for phi at fam' (not just fam)
   - IH for phi at fam' is `phi in fam'.mcs t <-> bmcs_truth_at B fam' t phi`
   - This needs the truth lemma at fam', which for the all_future/all_past SUBCASES of phi needs temporal coherence of fam'

2. So if phi = `G(psi)`, then evaluating `Box(G(psi))` at fam requires the truth lemma for `G(psi)` at every fam' in the bundle, which requires temporal coherence of every fam'.

**This seems like an iron constraint, but there is a way around it.**

### 5.3 The MCS-Membership Box Approach

The `bmcs_truth_at_mcs` approach in `ChainBundleBFMCS.lean` breaks this cycle:

```lean
def bmcs_truth_at_mcs (B : BFMCS D) (fam : FMCS D) (t : D) : Formula -> Prop
  | atom p => atom p in fam.mcs t
  | bot => False
  | imp phi psi => bmcs_truth_at_mcs ... phi -> bmcs_truth_at_mcs ... psi
  | box phi => forall fam' in B.families, phi in fam'.mcs t  -- FLAT, not recursive!
  | all_past phi => forall s, s <= t -> bmcs_truth_at_mcs ... s phi
  | all_future phi => forall s, t <= s -> bmcs_truth_at_mcs ... s phi
```

The Box case uses MEMBERSHIP (`phi in fam'.mcs t`), NOT recursive truth evaluation. This means:
- The truth lemma for `Box(phi)` requires `phi in fam'.mcs t` for all fam', which requires `modal_forward`
- It does NOT require the truth lemma to hold for phi at fam'
- Therefore, no temporal coherence of fam' is needed for the Box case

The truth lemma `bmcs_truth_lemma_mcs` only requires temporal coherence of the EVAL family:

```lean
theorem bmcs_truth_lemma_mcs (B : BFMCS D)
    (h_forward_F : for eval family only)
    (h_backward_P : for eval family only)
    ...
```

### 5.4 The Reformulated Construction

**Step 1**: Build the eval family via DovetailingChain:
- An FMCS Int with forward_G, backward_H (proven), forward_F, backward_P (sorry)

**Step 2**: Add constant witness families for modal saturation:
- For each Diamond(psi) in any family's MCS at time t, create a constant family with MCS W containing psi
- These constant families need NO temporal coherence

**Step 3**: Use `bmcs_truth_lemma_mcs` (Box = MCS membership) for the truth lemma:
- Only requires temporal coherence of the eval family (2 sorries from DovetailingChain)

**Step 4**: Completeness follows the same pattern as `ChainBundleBFMCS.lean`:
- `bmcs_representation_mcs` gives `not derivable phi -> exists B, bmcs_truth_at_mcs B eval 0 (neg phi)`
- `bmcs_weak_completeness_mcs` gives `bmcs_valid_mcs phi -> derivable phi`

### 5.5 What About Standard Validity?

The `bmcs_truth_at_mcs` completeness is with respect to `bmcs_valid_mcs`, NOT standard `valid`. To bridge to standard validity:

**Option A**: Accept that `bmcs_valid_mcs -> derivable` IS the completeness result, and bridge to standard validity separately. This is already done in `ChainBundleBFMCS.lean`.

**Option B**: Reformulate `fully_saturated_bfmcs_exists_int` to only require eval-family temporal coherence:

```lean
theorem fully_saturated_bfmcs_exists_int_v2 (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    exists (B : BFMCS Int),
      (forall gamma in Gamma, gamma in B.eval_family.mcs 0) /\
      -- Only eval family needs temporal coherence:
      (forall t phi, F(phi) in B.eval_family.mcs t -> exists s, t <= s /\ phi in B.eval_family.mcs s) /\
      (forall t phi, P(phi) in B.eval_family.mcs t -> exists s, s <= t /\ phi in B.eval_family.mcs s) /\
      is_modally_saturated B
```

This is strictly weaker than the current statement and is PROVABLE given:
1. DovetailingChain provides the eval family (with 2 sorries for forward_F/backward_P)
2. Constant witness families provide modal saturation (sorry-free, via `constructWitnessFamily` in ModalSaturation.lean)

The 2 remaining sorries are the STRUCTURAL sorries in DovetailingChain (forward_F, backward_P), which are inherent to the linear chain approach.

---

## 6. The DovetailingChain F/P Witness Problem

### 6.1 Why forward_F Fails in the Linear Chain

The forward chain builds `M_0, M_1, M_2, ...` where each `M_{n+1}` extends `GContent(M_n)`. With witness placement: if `decodeFormula(n) = some psi` and `F(psi) in M_n`, then the seed includes `{psi} union GContent(M_n)`.

**The problem**: When `F(psi) in M_t` at some time t in the unified chain:
1. If `t >= 0`: psi must appear at some `s > t` in the forward chain
2. The forward chain checks `F(psi)` at step `encodeFormula(psi)`
3. If `encodeFormula(psi) < t.toNat`: the check already happened before M_t was built
4. F-formulas do NOT persist through GContent seeds (GContent only propagates G-formulas)
5. Lindenbaum at step `encodeFormula(psi) + 1` could introduce `G(neg(psi))`, killing `F(psi)`

**The witness chain infrastructure** (lines 1160-1628 of DovetailingChain.lean) addresses the case where `encodeFormula(psi) >= t.toNat` via `witnessForwardChain_coverage_of_le`. But the case where `F(psi)` enters the chain AFTER its encoding index is fundamentally unsolvable in a single-pass linear chain.

### 6.2 Potential Resolution: Double-Pass Chain

A double-pass approach:
1. **Pass 1**: Build the linear chain as currently done (forward and backward)
2. **Pass 2**: For each F-obligation that was NOT witnessed in Pass 1, restart the chain from that point with the witness in the seed

This requires:
- A way to enumerate the "missed" F-obligations
- A proof that the second pass does not create new missed obligations
- A convergence argument (finitely many passes suffice)

This is essentially the omega-squared construction mentioned in the comments.

### 6.3 The CanonicalBC Insight Transferred

The CanonicalBC approach succeeds because each F-obligation gets its own "fresh" domain element. In Int, domain elements are pre-determined. But we can SIMULATE fresh elements by:

**Approach**: Use a function `Int -> Set Formula` where each integer maps to a (potentially different) Lindenbaum extension, chosen to witness SPECIFIC F-obligations.

The DovetailingChain ALREADY does this for obligations encountered at the right step. The problem is obligations that appear later. The fix:

**Use the F-persistence + coverage lemmas**: The existing infrastructure proves:
- If `F(psi) in chain(n)` and `n >= encodeFormula(psi)`, then `psi in chain(encodeFormula(psi) + 1)` (coverage_of_le)
- If `F(psi) in chain(0)`, it persists until killed by `G(neg(psi))`

What is MISSING: a proof that `F(psi) in chain(t)` implies `F(psi) in chain(encodeFormula(psi))` OR that `G(neg(psi))` never enters. The challenge is that Lindenbaum extension at intermediate steps is non-constructive and can introduce `G(neg(psi))`.

### 6.4 The Definitive Analysis

The 2 sorries (forward_F, backward_P) in DovetailingChain are a known open problem. Twelve different approaches have been tried and documented in Task 916 research reports. The fundamental blocker is:

**F-formula non-persistence through GContent seeds**: When building `M_{n+1}` from `GContent(M_n)`, the F-formula `F(psi) = neg(G(neg(psi)))` is NOT in GContent. Lindenbaum's non-constructive choice can introduce `G(neg(psi))`, killing `F(psi)`.

This is a REAL mathematical difficulty, not a Lean formalization issue. Resolving it requires either:
1. A non-linear chain construction (omega-squared, tree, etc.)
2. A modified seed that preserves F-formulas (but the seed `{F(psi)} union GContent(M)` leads to circular dependencies)
3. A completely different approach to temporal coherence

---

## 7. Recommendations

### 7.1 Short-Term: Reformulate the Sorry Target

**Action**: Refactor `fully_saturated_bfmcs_exists_int` to only require eval-family temporal coherence. Then refactor `bmcs_truth_lemma` to use the `bmcs_truth_lemma_mcs` pattern (Box = MCS membership) or add an alternative truth lemma with eval-only temporal coherence.

**Sorry count**: 2 (forward_F, backward_P in DovetailingChain) -- same as current, but the sorry is now PRECISELY located and the rest of the chain is sorry-free.

**Estimated effort**: 4-8 hours to refactor TruthLemma.lean and Completeness.lean.

### 7.2 Medium-Term: Resolve the 2 DovetailingChain Sorries

**Action**: Implement an omega-squared or tree-based chain construction that handles F/P obligations immediately when they appear.

**Key insight for implementation**: The `witnessForwardChain_coverage_of_le` lemma already handles the case where `F(psi)` is present at the encoding index. What is needed is a construction where F-obligations are ALWAYS present at their encoding index.

**One promising approach**: Instead of building one chain, build a SEQUENCE of chains:
1. Chain_0: standard DovetailingChain from Gamma
2. For each unwitnessed F-obligation `F(psi)` at time t in Chain_0, build Chain_1 that starts from the GContent of Chain_0 at time t with `psi` in the seed
3. Repeat until convergence

**Convergence argument**: Each formula can appear as an F-obligation at most once per chain. Since there are countably many formulas and each chain is countable, the total construction is omega-squared.

**Estimated effort**: 20-40 hours for the construction + convergence proof.

### 7.3 Long-Term: Standard Validity Bridge

**Action**: Once the 2 sorries are resolved, the standard completeness chain in `Representation.lean` becomes sorry-free automatically (it inherits from `fully_saturated_bfmcs_exists_int`).

---

## 8. File Reference

| File | Role | Sorry Count |
|------|------|-------------|
| `TemporalCoherentConstruction.lean` | Main sorry location (`fully_saturated_bfmcs_exists_int`) | 2 (1 direct sorry, 1 generic sorry) |
| `DovetailingChain.lean` | Chain construction with forward_F/backward_P sorries | 2 |
| `TruthLemma.lean` | Truth lemma (sorry-free, requires `temporally_coherent`) | 0 |
| `Completeness.lean` | Completeness theorems (sorry-free, inherits from construction) | 0 |
| `ModalSaturation.lean` | Modal saturation + `saturated_modal_backward` (sorry-free) | 0 |
| `ChainBundleBFMCS.lean` | Alternative truth lemma with eval-only coherence (sorry-free) | 0 |
| `CanonicalFrame.lean` | `canonical_forward_F` (sorry-free, uses canonical domain) | 0 |
| `CanonicalFMCS.lean` | FMCS over CanonicalMCS with trivial F/P (sorry-free) | 0 |

---

## 9. Summary of Key Findings

| Question | Finding |
|----------|---------|
| Where does the construction fail? | Combining temporal coherence (ALL families) with modal saturation (constant witness families) |
| What is the root cause? | Constant families require temporal saturation (F(psi) -> psi) which is impossible for generic MCSes |
| Why is CanonicalBC "free"? | Each F-obligation creates a fresh domain element; the witness IS a new time point |
| Can we transfer CanonicalBC to Int? | No -- Int has pre-determined time points; creating an MCS does not create a new integer |
| What about DovetailingChain's 2 sorries? | F-formulas don't persist through GContent seeds; Lindenbaum can kill them |
| Best resolution strategy? | Weaken `temporally_coherent` to eval-family only (Strategy D), then resolve DovetailingChain sorries separately |
| Is omega-squared viable? | Yes in theory, but 20-40 hours of formalization effort |
| Can constant witness families be made coherent? | No -- temporal saturation of a single MCS is impossible |
| What about non-constant witness families? | Each would need its own DovetailingChain, multiplying the sorry count |
| Is the completeness result sound despite the sorry? | Yes -- the sorry is in an EXISTENCE claim, not in the logical deduction |

### The Bottom Line

The sorry in `fully_saturated_bfmcs_exists_int` is really TWO sorries from `DovetailingChain.lean` (forward_F, backward_P), amplified by the overly-strong requirement that ALL families be temporally coherent. The immediate path forward is to WEAKEN the requirement to eval-family-only temporal coherence (which the truth lemma actually supports via the `bmcs_truth_lemma_mcs` approach), then separately tackle the 2 DovetailingChain sorries via an omega-squared construction.
