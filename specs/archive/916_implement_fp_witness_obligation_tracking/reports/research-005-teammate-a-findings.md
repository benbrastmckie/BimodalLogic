# Research Report: Task #916 (Teammate A -- Mathematical Characterization of Chain-Based Approach Failures)

**Task**: Close forward_F and backward_P sorries in DovetailingChain.lean
**Date**: 2026-02-20
**Focus**: Mathematical characterization of WHY all chain-based approaches fail
**Session**: agent_system-1768239349

## Summary

This report provides a rigorous mathematical characterization of the obstacles preventing proof of `forward_F` and `backward_P` in the dovetailing chain construction. The analysis covers: (1) the exact problem statement and what these properties require semantically, (2) why the flat chain (v003) approach fails due to Lindenbaum opacity, (3) why the omega^2 with outer-MCS check (v004) approach fails because `generalized_forward_temporal_witness_seed_consistent` is mathematically false, and (4) the fundamental obstacle rooted in the non-constructive nature of Zorn-based Lindenbaum extension.

---

## 1. The Problem Statement

### 1.1 Exact Sorry Locations and Goal Types

The two sorries are at lines 1621 and 1628 of `Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`:

**forward_F** (line 1617-1621):
```lean
lemma buildDovetailingChainFamily_forward_F (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    forall t : Int, forall phi : Formula,
      Formula.some_future phi in (buildDovetailingChainFamily Gamma h_cons).mcs t ->
      exists s : Int, t < s /\ phi in (buildDovetailingChainFamily Gamma h_cons).mcs s := by
  sorry
```

**backward_P** (line 1624-1628):
```lean
lemma buildDovetailingChainFamily_backward_P (Gamma : List Formula) (h_cons : ContextConsistent Gamma) :
    forall t : Int, forall phi : Formula,
      Formula.some_past phi in (buildDovetailingChainFamily Gamma h_cons).mcs t ->
      exists s : Int, s < t /\ phi in (buildDovetailingChainFamily Gamma h_cons).mcs s := by
  sorry
```

### 1.2 Semantic Meaning

In this bimodal temporal logic (TM logic), the operators are:

| Symbol | Lean Name | Meaning |
|--------|-----------|---------|
| G(phi) | `Formula.all_future phi` | phi holds at ALL strictly future times |
| H(phi) | `Formula.all_past phi` | phi holds at ALL strictly past times |
| F(phi) | `Formula.some_future phi` | phi holds at SOME strictly future time |
| P(phi) | `Formula.some_past phi` | phi holds at SOME strictly past time |

The key definitions:
- `F(phi) = neg(G(neg(phi)))` (existential future is dual of universal future)
- `P(phi) = neg(H(neg(phi)))` (existential past is dual of universal past)
- `GContent(M) = {phi | G(phi) in M}` (formulas whose G-closure is in M)
- `HContent(M) = {phi | H(phi) in M}` (formulas whose H-closure is in M)

**forward_F** states: if `F(phi)` ("phi will hold at some future time") is in the MCS at time `t`, then there must exist a STRICTLY LATER time `s > t` where `phi` itself is in the MCS at time `s`. This is the existential witness property for the "sometime future" operator.

**backward_P** is the symmetric property for the past direction.

### 1.3 Why These Properties Matter

These are two of the four temporal coherence properties needed for the `temporal_coherent_family_exists_theorem` (line 1643), which replaces the AXIOM `temporal_coherent_family_exists` with a THEOREM (with sorry debt). The other two properties -- `forward_G` and `backward_H` -- are fully proven. The forward_F and backward_P properties are existential witness requirements: they demand that the chain construction actually places witnesses at the right positions.

### 1.4 The Construction Architecture

The chain is built as follows:
- **Forward chain** (`dovetailForwardChainMCS`): Nat-indexed, step 0 is a shared base MCS, step n+1 extends `GContent(chain(n))` (or `{psi} union GContent(chain(n))` when witnessing)
- **Backward chain** (`dovetailBackwardChainMCS`): Nat-indexed, symmetric using `HContent`
- **Unified family** (`dovetailChainSet`): Int-indexed, non-negative times use the forward chain, negative times use the backward chain, both sharing the base MCS at time 0

At step n+1, the chain checks `decodeFormula(n)`:
- If `decodeFormula(n) = some psi` and `F(psi) in chain(n)`: extend `{psi} union GContent(chain(n))` via Lindenbaum
- Otherwise: extend `GContent(chain(n))` via Lindenbaum

---

## 2. Why Flat Chains Fail (v003 Approach)

### 2.1 The Coverage Gap

The flat chain processes each formula EXACTLY ONCE. Formula `psi` is processed at step `encodeFormula(psi)`. The existing coverage lemma (`witnessForwardChain_coverage_of_le`, line 1528) proves:

> If `F(psi) in chain(n)` and `encodeFormula(psi) <= n`, then `psi in chain(encodeFormula(psi) + 1)`.

This produces a witness at step `encodeFormula(psi) + 1`. But for `forward_F`, we need a witness at some step `s > n` (converted to the Int-indexed family). There are two problematic cases:

**Case 1: `encodeFormula(psi) < n`** (formula was already processed).

The witness step `encodeFormula(psi) + 1 <= n`. The witness is at a step BEFORE or EQUAL to `n`. Since `psi` is not a G-formula, it does not propagate via GContent. There is no mechanism to make `psi` appear at any step after `n`. The flat chain only processes `psi` once, and that opportunity has passed.

**Case 2: `encodeFormula(psi) > n`** (formula will be processed later).

We need `F(psi)` to PERSIST from step `n` to step `encodeFormula(psi)`. But F-formulas do NOT persist through the chain. This is the Lindenbaum opacity problem, detailed next.

### 2.2 The Lindenbaum Opacity Problem

The core issue is that `F(psi)` can be "killed" at any step. Here is the precise mechanism:

**Step 1**: `F(psi) in chain(n)`. Since `F(psi) = neg(G(neg(psi)))`, this means `G(neg(psi)) NOT in chain(n)`.

**Step 2**: By the T-axiom (`G(phi) -> phi`), if `G(G(neg(psi))) in chain(n)`, then `G(neg(psi)) in chain(n)`. But `G(neg(psi)) NOT in chain(n)`, so `G(G(neg(psi))) NOT in chain(n)`.

**Step 3**: Since `GContent(chain(n)) = {phi | G(phi) in chain(n)}`, we have `G(neg(psi)) NOT in GContent(chain(n))` (because that would require `G(G(neg(psi))) in chain(n)`, which we just excluded).

**Step 4**: The seed for `chain(n+1)` is either `GContent(chain(n))` or `{witness} union GContent(chain(n))`. In either case, `G(neg(psi))` is NOT in the seed.

**Step 5**: HOWEVER, Lindenbaum extends the seed to a MAXIMAL consistent set. This extension is performed by Zorn's lemma / Classical.choice and is OPAQUE -- we have no control over which formulas enter. Since `G(neg(psi))` is NOT in the seed and `neg(G(neg(psi))) = F(psi)` is also NOT in the seed, the seed is consistent with EITHER `G(neg(psi))` or `F(psi)`. Lindenbaum's choice is unconstrained.

**Step 6**: If Lindenbaum adds `G(neg(psi))` to `chain(n+1)`, then `F(psi) NOT in chain(n+1)`. Moreover, by the 4-axiom (`G(phi) -> G(G(phi))`), `G(G(neg(psi))) in chain(n+1)`, so `G(neg(psi)) in GContent(chain(n+1))`, and `G(neg(psi))` propagates to ALL subsequent chain elements. The F-formula is killed permanently.

### 2.3 G(G(neg(psi))) and F(psi) Can Coexist

A critical subtlety: `G(G(neg(psi)))` and `F(psi)` CAN coexist in the SAME MCS. This is because:

- `G(G(neg(psi)))` means "at all strictly future times t, at all strictly future times t' > t, neg(psi) holds"
- `F(psi)` means "at some strictly future time, psi holds"

These are compatible in models with the strict future interpretation: psi can hold at the immediate next time point, while neg(psi) holds at all times after that.

The 4-axiom gives `G(phi) -> G(G(phi))` but NOT `G(G(phi)) -> G(phi)`. So `G(G(neg(psi))) in chain(n)` does NOT imply `G(neg(psi)) in chain(n)` -- only the T-axiom applied to `G(G(neg(psi)))` gives `G(neg(psi)) in chain(n)`.

Wait -- the T-axiom IS `G(phi) -> phi`. Applying it to `phi = G(neg(psi))`: `G(G(neg(psi))) -> G(neg(psi))`. So if `G(G(neg(psi))) in chain(n)`, then `G(neg(psi)) in chain(n)`, contradicting `F(psi) in chain(n)`.

**Correction**: `G(G(neg(psi)))` CANNOT coexist with `F(psi)` in an MCS. The T-axiom immediately derives the contradiction. So Step 2 above is correct and Step 3 follows.

However, the CRITICAL point is: while `G(G(neg(psi)))` cannot coexist with `F(psi)` at step `n`, Lindenbaum at step `n+1` starts from a seed that contains NEITHER `F(psi)` NOR `G(neg(psi))`. The seed is `GContent(chain(n))` (possibly with a witness). Since `G(neg(psi)) NOT in GContent(chain(n))`, but also `F(psi) NOT in GContent(chain(n))` (unless `G(F(psi)) in chain(n)`, which is not generally the case), Lindenbaum is free to choose either.

### 2.4 F(psi) -> G(F(psi)) is NOT Derivable

For `F(psi)` to propagate via GContent from step `n` to step `n+1`, we would need `G(F(psi)) in chain(n)`, i.e., `F(psi) in GContent(chain(n))`. This requires the principle `F(psi) -> G(F(psi))`, which states "if something will happen, then it will always be the case that it will happen."

This principle is NOT derivable in TM logic with STRICT future semantics. In strict future (`s > t`), `F(psi)` at time `t` says "psi at some s > t". But `G(F(psi))` at time `t` says "for all s > t, there exists s' > s such that psi at s'." If psi holds only at time `t+1`, then `F(psi)` holds at `t` but `G(F(psi))` fails at `t` because at time `t+1`, F(psi) requires psi at some s' > t+1, which may not exist.

This is confirmed by teammate C's analysis in research-003-teammate-c-findings.md.

### 2.5 Summary of Flat Chain Failure

The flat chain fails for two independent reasons:

1. **Case `encodeFormula(psi) < n`**: The witness fires at `encodeFormula(psi) + 1 <= n`, which is before the required time. The formula is processed only once, and psi does not propagate forward.

2. **Case `encodeFormula(psi) >= n`**: F(psi) must persist from step `n` to step `encodeFormula(psi)`, but Lindenbaum can kill it at any intermediate step by adding `G(neg(psi))`. Once killed, `G(neg(psi))` propagates forward permanently.

---

## 3. Why Omega^2 with Outer-MCS Check Fails (v004 Approach)

### 3.1 The v004 Architecture

The v004 plan proposed an omega^2 (inner chain) construction:

```
outerChain(0) = Lindenbaum(base)
outerChain(t+1) = innerChainFinal(outerChain(t))

innerChain(M, 0) = Lindenbaum(GContent(M))
innerChain(M, k+1) =
  match decodeFormula(k) with
  | none => innerChain(M, k)
  | some psi =>
    if F(psi) in M then       -- CHECK AGAINST OUTER M
      Lindenbaum({psi} union GContent(innerChain(M, k)))
    else
      innerChain(M, k)
```

The key innovation was checking `F(psi) in M` (the OUTER MCS) rather than `F(psi) in innerChain(M, k)`. This avoids the F-formula persistence problem within the inner chain.

### 3.2 The Generalized Consistency Lemma

This architecture requires a new consistency lemma:

> **`generalized_forward_temporal_witness_seed_consistent`**: If M and N are MCSes, `GContent(M) subset N`, and `F(psi) in M`, then `{psi} union GContent(N)` is consistent.

This is STRONGER than the existing `forward_temporal_witness_seed_consistent`, which only handles the case `M = N` (i.e., `{psi} union GContent(M)` is consistent when `F(psi) in M`).

### 3.3 The Generalized Lemma is Mathematically FALSE

The generalized lemma fails. Here is the precise counterexample:

**Construction**:
1. Let M be an MCS containing `F(psi)`. Then `G(neg(psi)) NOT in M`.
2. Since `G(G(neg(psi))) NOT in M` (by T-axiom), `G(neg(psi)) NOT in GContent(M)`.
3. Let `N = Lindenbaum(GContent(M))`. N is an MCS extending `GContent(M)`.
4. Since `G(neg(psi)) NOT in GContent(M)`, but `GContent(M)` does not contain `F(psi) = neg(G(neg(psi)))` either (unless `G(F(psi)) in M`, which is not guaranteed), Lindenbaum is free to add `G(neg(psi))` to N.
5. Suppose N contains `G(neg(psi))`. By the T-axiom: `neg(psi) in N`. By the 4-axiom: `G(G(neg(psi))) in N`, hence `G(neg(psi)) in GContent(N)`.
6. Now consider `{psi} union GContent(N)`. This contains both `psi` and `neg(psi)` (from `G(neg(psi)) in GContent(N)`, which gives `neg(psi) in GContent(N)` via the T-axiom applied to `G(neg(psi)) -> neg(psi)` ... wait, `neg(psi) in GContent(N)` means `G(neg(psi)) in N`, which is true. But `neg(psi) in GContent(N)` means `G(neg(psi)) in N`, which we have. By the T-axiom, `neg(psi) in N`.

Let me be more precise. `GContent(N) = {phi | G(phi) in N}`. So `neg(psi) in GContent(N)` iff `G(neg(psi)) in N`. We have `G(neg(psi)) in N` by assumption, so `neg(psi) in GContent(N)`.

Therefore `{psi} union GContent(N)` contains both `psi` and `neg(psi)`, which is trivially inconsistent (from `psi` and `neg(psi)`, derive `bot` by modus ponens with `psi -> (neg(psi) -> bot)`).

**Why the original lemma avoids this**: `forward_temporal_witness_seed_consistent` uses `M = N`. In that case, `G(neg(psi)) NOT in M` (since `F(psi) in M`), so `neg(psi) NOT in GContent(M)`. There is no counterexample because the F-formula constraint is on the SAME MCS.

**Why the generalized lemma fails**: The generalized lemma separates the F-formula constraint (on M) from the GContent source (on N). N can contain `G(neg(psi))` even though M does not, because N is a DIFFERENT MCS.

### 3.4 Consequence for the v004 Architecture

Since `generalized_forward_temporal_witness_seed_consistent` is false, the inner chain construction cannot check F-formulas against the outer MCS M. It must check against the inner chain predecessor, reverting to the standard `forward_temporal_witness_seed_consistent`. But then the inner chain has the SAME persistence problem as the flat chain: F(psi) may be killed at any inner step by Lindenbaum opacity.

### 3.5 All Inner Chain Variants Share the Same Obstacle

Whether the inner chain checks F(psi) in:
- The outer MCS M (requires the false generalized lemma)
- The inner chain predecessor (same persistence problem as flat chain)
- Some intermediate state (requires another false generalized lemma variant)

The fundamental issue is the same: Lindenbaum can kill F(psi) at any step.

---

## 4. The Fundamental Obstacle

### 4.1 Root Cause: Zorn-Based Lindenbaum is an Opaque Existence Proof

The `set_lindenbaum` lemma (used throughout the construction) states:

> If S is consistent, there exists an MCS M with S subset M.

The proof uses Zorn's lemma (equivalently, Classical.choice in Lean 4). The resulting MCS M is a PURE EXISTENCE claim -- we know M exists and extends S, but we have NO information about which additional formulas M contains beyond S.

**This is not a bug in the implementation.** It is a fundamental property of the Zorn-based approach. The MCS produced by `Classical.choose` for the Zorn application is determined by the choice function, but from a logical standpoint, any consistent superset of S that is maximal consistent would satisfy the specification.

### 4.2 The Core Tension

The forward_F proof requires TWO properties of the chain:

1. **GContent propagation**: `GContent(chain(n)) subset chain(n+1)` -- ensures G-formulas propagate forward (needed for forward_G)
2. **Witness placement**: When `F(psi) in chain(n)` and psi is being processed at step n, `psi in chain(n+1)` -- ensures the F-witness is placed

Property (1) is satisfied because the seed for `chain(n+1)` always contains `GContent(chain(n))`.

Property (2) is satisfied AT THE PROCESSING STEP because the seed contains `{psi} union GContent(chain(n))`.

The problem is that property (2) only fires ONCE (at step `encodeFormula(psi)`) or when F(psi) happens to be alive at the processing step. If F(psi) is dead (killed by Lindenbaum at an earlier step), property (2) does not fire. And if it fires at a step before `n`, the witness is at a step before `n`.

### 4.3 Why This Is NOT a Bug in Our Approach

The Lindenbaum opacity problem is not unique to our implementation. It is a well-known challenge in temporal logic completeness proofs. The standard resolution in the literature (Goldblatt 1992, Blackburn et al. 2001) uses one of:

1. **Non-strict future semantics** (G includes the present): This makes `G(phi) -> phi` trivial and `F(psi) -> G(F(psi))` derivable, allowing F-formulas to propagate via GContent. Our logic uses STRICT future, where this derivation fails.

2. **Tree-based canonical models**: Instead of building a LINEAR chain, the canonical model is a TREE of MCSes where each F-obligation gets its own branch. This avoids the persistence problem entirely but requires a substantially different architecture.

3. **Fischer-Ladner closure / finite model property**: For logics with the finite model property, one can work with a finite set of formulas and ensure all obligations are met within a bounded number of steps. Our logic has the FMP (partially implemented in `Theories/Bimodal/Metalogic/FMP/`), but connecting it to the chain construction is non-trivial.

4. **Selective Lindenbaum**: Some proofs use a Lindenbaum construction that explicitly avoids adding `G(neg(psi))` when `F(psi)` is an obligation. This requires a CONSTRUCTIVE (formula-by-formula) Lindenbaum rather than the Zorn-based approach, and has been attempted in the boneyard (`Theories/Bimodal/Boneyard/Bundle/TemporalLindenbaum.lean`) with 5 unresolved sorries.

### 4.4 The Proof-Theoretic View

From a proof-theoretic perspective, the obstacle can be stated precisely:

**Theorem (informal)**: In TM logic with strict future semantics, there is no derivation of `F(psi) -> G(F(psi))`.

**Consequence**: Given an MCS M with `F(psi) in M`, the set `GContent(M) = {phi | G(phi) in M}` does NOT contain `F(psi)`. Therefore, when we build `chain(n+1) = Lindenbaum(GContent(chain(n)))`, the new MCS `chain(n+1)` is NOT guaranteed to contain `F(psi)`.

**Consequence of consequence**: F-formula obligations do NOT propagate through the chain's GContent mechanism. The ONLY way to guarantee a formula enters an MCS is to place it in the seed. But the seed at each step can contain at most ONE witness (because `{psi_1, psi_2} union GContent(M)` may be inconsistent when `F(psi_1)` and `F(psi_2)` are both in M but `psi_1` and `psi_2` are contradictory -- e.g., `psi_1 = p` and `psi_2 = neg(p)`).

### 4.5 The Persistence Impossibility

More precisely, the obstacle is:

**No chain architecture using Zorn-based Lindenbaum can guarantee F-formula persistence**, because:

1. At each step, the seed is `GContent(prev) union {at most one witness}`.
2. `F(psi)` is NOT in `GContent(prev)` (because `G(F(psi))` is not generally in prev).
3. `F(psi)` is NOT the witness (the witness is `psi`, not `F(psi)`).
4. Therefore `F(psi)` is not in the seed, and Lindenbaum may or may not include it.

The witness fires only when `F(psi)` is alive at the processing step. Between processing steps, `F(psi)` can die. And each formula has only finitely many processing opportunities in any bounded interval.

---

## 5. Evidence Summary

### 5.1 Codebase Evidence

| Evidence | Location | Finding |
|----------|----------|---------|
| forward_F sorry | DovetailingChain.lean:1621 | Unsupported by existing chain architecture |
| backward_P sorry | DovetailingChain.lean:1628 | Symmetric unsupported sorry |
| coverage_of_le lemma | DovetailingChain.lean:1528 | Only works when `encodeFormula(psi) <= n` |
| F-persistence | DovetailingChain.lean:1444-1480 | Only shows F persists if NOT killed, not that it WON'T be killed |
| G propagation | DovetailingChain.lean:1234-1249 | G propagates forward (proven), but F does not |
| Boneyard TemporalLindenbaum | Boneyard/Bundle/TemporalLindenbaum.lean | 5 sorries from constructive Lindenbaum attempt |
| F/G dichotomy | DovetailingChain.lean:1406-1415 | At each step, exactly one of F(psi) or G(neg(psi)) holds |
| Generalized consistency failure | implementation-004.md:128-130 | Confirmed false by implementation attempt |

### 5.2 Mathematical Evidence

| Claim | Status | Source |
|-------|--------|--------|
| F(psi) -> G(F(psi)) not derivable | CONFIRMED | research-003-teammate-c-findings.md |
| G(G(neg(psi))) and F(psi) cannot coexist in MCS | CONFIRMED (T-axiom) | This report Section 2.3 |
| G(neg(psi)) not in GContent when F(psi) present | CONFIRMED | This report Section 2.2, Steps 2-3 |
| Lindenbaum can add G(neg(psi)) to chain(n+1) | CONFIRMED | seed does not constrain this choice |
| generalized_forward_temporal_witness_seed_consistent is FALSE | CONFIRMED | This report Section 3.3, counterexample |
| Flat chain insufficient for forward_F | CONFIRMED | Two independent failure cases |
| Omega^2 with outer check insufficient | CONFIRMED | Depends on false lemma |
| Inner chain with inner check has same problem | CONFIRMED | Same persistence issue at inner level |

---

## 6. Confidence Level

**Confidence: HIGH (95%)** that the current chain architecture cannot prove forward_F or backward_P without either:

(a) Changing the chain definition to provide additional structural guarantees, or
(b) Replacing Zorn-based Lindenbaum with a construction that controls which formulas enter the MCS.

**Confidence: HIGH (95%)** that `generalized_forward_temporal_witness_seed_consistent` is mathematically false (counterexample provided and independently confirmed by implementation attempt).

**Confidence: MEDIUM (70%)** that the constructive Lindenbaum approach (option b) is feasible -- the boneyard attempt failed, but the failure mode (maximality proof gap) might be addressable with different techniques. However, this would require 40-60 hours of work with high risk.

**Confidence: HIGH (90%)** that a tree-based canonical model approach would resolve the problem, but at the cost of a major architectural refactoring (estimating 50-80 hours).

---

## 7. Viable Paths Forward

### 7.1 Path A: F-Preserving Lindenbaum (New Idea)

Instead of the Zorn-based `set_lindenbaum`, define a Lindenbaum construction that takes a set of "preservation constraints" (formulas that must NOT be contradicted). Given consistent seed S and a finite set of formulas `{F(psi_1), ..., F(psi_k)}` that should be preserved, produce an MCS M extending S such that for each i, either `F(psi_i) in M` or `psi_i in M`.

**Feasibility**: MEDIUM. This requires showing that `S union {F(psi_1), ..., F(psi_k)}` is consistent (not guaranteed -- F(psi_i) may conflict with other formulas in S). However, if we only preserve ONE F-formula at a time (the one being witnessed at the current step), and the preservation target is `F(psi)` rather than `psi`, then `S union {F(psi)} = S union {neg(G(neg(psi)))}` is consistent iff `G(neg(psi)) NOT in S`. Since `G(neg(psi)) NOT in GContent(prev)` (proven), this IS consistent. A Lindenbaum extension preserving `F(psi)` could be obtained.

**But**: This only preserves ONE F-formula per step. Other F-formulas can still die.

### 7.2 Path B: Re-enumeration with Nat.unpair (Partially Viable)

Use `decodeFormula(Nat.unpair(n).2)` instead of `decodeFormula(n)` to process each formula infinitely often. Combined with a "race condition" argument:

Given `F(psi) in chain(n)`, either:
- F(psi) persists forever -> choose a processing step for psi after n, witness fires
- G(neg(psi)) enters at some first step j0 > n -> F(psi) is alive on [n, j0-1]

For the second case, if there is a processing step for psi in the interval (n, j0), the witness fires before F(psi) dies. The problem is that j0 could equal n+1, leaving NO gap.

**Remaining gap**: Must prove that if F(psi) dies at step n+1 (G(neg(psi)) enters), then psi was NOT processed at step n+1. But the chain processes some formula at every step, and if it happens to process psi at step n+1, the witness fires BEFORE Lindenbaum is called (psi is placed in the seed), so the resulting MCS contains psi regardless of whether G(neg(psi)) also enters.

**This is actually a viable argument!** At step n+1, if `decodeFormula(something) = some psi` and `F(psi) in chain(n)`, then the seed is `{psi} union GContent(chain(n))`, and `psi in chain(n+1)`. The witness is at step n+1 > n. The question is whether `decodeFormula(something) = some psi` at the right step. With Nat.unpair, psi is processed at infinitely many steps.

The race condition argument would be: EITHER F(psi) persists until a processing step for psi (witness fires), OR F(psi) is killed between two consecutive processing steps for psi (but psi was witnessed at the earlier processing step if F(psi) was alive then). The gap is: at the earlier processing step, F(psi) might have been alive but the step was BEFORE n.

**This path requires further analysis** to determine if the argument closes.

### 7.3 Path C: Accept Sorry Debt (Pragmatic)

Document the mathematical obstruction precisely, maintain the 2 sorries as proof debt, and note that the theorem has been upgraded from an AXIOM to a THEOREM-with-sorry. This is honest about the incompleteness and preserves all 40+ existing lemmas.

---

## 8. Recommendations

1. **Investigate Path B (re-enumeration with race condition)** more carefully. The key question is whether the race condition argument can be made rigorous. If F(psi) is alive at ANY processing step for psi that occurs after n, the witness fires. The argument needs to handle the case where F(psi) dies before the first processing step after n.

2. **Do NOT attempt the generalized consistency lemma** again. It is mathematically false (Section 3.3). Any approach depending on it is doomed.

3. **Do NOT attempt constructive Lindenbaum** without a clear plan for the maximality proof. The boneyard attempt demonstrates this is extremely difficult.

4. **Consider the tree-based canonical model** as a long-term strategic option if the chain approach is definitively abandoned.

---

## References

- DovetailingChain.lean: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/DovetailingChain.lean`
- Prior research (v004): `/home/benjamin/Projects/ProofChecker/specs/916_implement_fp_witness_obligation_tracking/reports/research-004.md`
- Phase 3 handoff: `/home/benjamin/Projects/ProofChecker/specs/916_implement_fp_witness_obligation_tracking/handoffs/phase-3-handoff-20260220.md`
- Teammate C analysis: `/home/benjamin/Projects/ProofChecker/specs/916_implement_fp_witness_obligation_tracking/reports/research-003-teammate-c-findings.md`
- Implementation v004 plan: `/home/benjamin/Projects/ProofChecker/specs/916_implement_fp_witness_obligation_tracking/plans/implementation-004.md`
- TemporalContent definitions: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Metalogic/Bundle/TemporalContent.lean`
- Axiom definitions: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/ProofSystem/Axioms.lean`
- Formula definitions: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Syntax/Formula.lean`
- Boneyard TemporalLindenbaum: `/home/benjamin/Projects/ProofChecker/Theories/Bimodal/Boneyard/Bundle/TemporalLindenbaum.lean`
- Goldblatt, R. "Logics of Time and Computation" (1992)
- Blackburn, P., de Rijke, M., Venema, Y. "Modal Logic" (2001)
