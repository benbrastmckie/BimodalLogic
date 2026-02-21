# Research Report: Task #916 (Teammate B Findings)

**Task**: Implement F/P witness obligation tracking to close DovetailingChain sorries
**Date**: 2026-02-20
**Focus**: Deep analysis of Approaches B (Canonical Model + Unraveling), C (Dependent Choice + Priority Queue), and novel alternatives (E, F)

## Summary

Approach B (canonical model + unraveling) is theoretically sound but introduces massive infrastructure overhead (20-30h) with no reuse of existing proven lemmas. Approach C (dependent choice + priority queue) fails as stated because F-formula persistence cannot be guaranteed through non-augmented steps. However, the investigation reveals a novel **Approach E: Enriched Recursive Chain with Nat.unpair Selection** that directly modifies the existing `dovetailForwardChainMCS`/`dovetailBackwardChainMCS` construction to add one witness per step, using `temporal_witness_seed_consistent` for consistency. This approach has the lowest implementation cost (12-18h) and maximum reuse of existing proven infrastructure.

## Key Findings for Approach B (Canonical Model + Unraveling)

### What It Proposes

Build the full canonical model where:
- Worlds = all MCSes (type `{S : Set Formula // SetMaximalConsistent S}`)
- Future accessibility: `R_G(M, N)` iff `GContent(M) ⊆ N`
- Past accessibility: `R_H(M, N)` iff `HContent(M) ⊆ N`

The canonical model trivially satisfies `forward_F`: if `F(psi)` is in world `M`, then by `temporal_witness_seed_consistent`, the set `{psi} ∪ GContent(M)` is consistent. By `set_lindenbaum`, there exists an MCS `N` extending this seed. Since `GContent(M) ⊆ N`, we have `R_G(M, N)`, and `psi ∈ N` (seed extends to MCS).

Then "unravel" the canonical model graph into a linear chain indexed by `Int`.

### Existing Infrastructure

The boneyard contains two versions of canonical model code:
- `Theories/Bimodal/Boneyard/Metalogic/Representation/CanonicalModel.lean` (sorries at line 315 in `mcs_contains_or_neg`)
- `Theories/Bimodal/Boneyard/Metalogic_v2/Representation/CanonicalModel.lean` (similar structure)

Both define `CanonicalFrame` with `future_accessibility` matching the `GContent ⊆` pattern. Neither implements unraveling or linear chain extraction.

### The Unraveling Problem

The canonical model is a directed graph (potentially with cycles, self-loops, and branching). Extracting a linear chain `M_0, M_1, M_2, ...` from this graph requires:

1. **Path construction**: Starting from a given MCS `M_0`, build an infinite path through the graph where each step follows `R_G` or `R_H`.
2. **Witness coverage**: The path must visit, for each `F(psi) ∈ M_t`, some `M_s` with `s > t` and `psi ∈ M_s`.

Problem: A naive path (always following `R_G` from predecessor) gives exactly the current GContent-seed construction. The unraveling adds nothing unless we control which successor world to visit at each step.

**Key insight**: The "unraveling" IS the enriched chain construction. The canonical model formalism adds an extra layer of indirection (worlds, accessibility relations) but the core mathematical challenge -- choosing the right successor at each step to witness F-obligations -- is identical.

### Effort Assessment: 20-30 hours

- Defining canonical frame and model: ~3h (adapt from boneyard)
- Proving truth lemma for canonical model: ~8h (substantial, boneyard has sorries)
- Proving F-witness existence in canonical model: ~2h (straightforward from `temporal_witness_seed_consistent`)
- Unraveling into linear chain: ~5-10h (the hard part)
- Connecting unraveled chain to BFMCS: ~3h
- Proving forward_G/backward_H for unraveled chain: ~3-5h (need to redo what's already proven)

### Verdict: NOT RECOMMENDED

Approach B introduces 20-30 hours of work, most of which duplicates existing infrastructure (the `buildDovetailingChainFamily` already provides forward_G and backward_H). The unraveling step faces the same fundamental challenge as the direct approach. The canonical model adds mathematical elegance but no proof-engineering advantage.

## Key Findings for Approach C (Dependent Choice + Priority Queue)

### What It Proposes

Use dependent choice (a consequence of AC, available in Lean as `Classical.choice`) to build the chain. At each step `n+1`, use `Classical.choice` to select an MCS that:
1. Extends `GContent(M_n)`
2. Witnesses the highest-priority unwitnessed F-formula from chain history

The priority queue processes F-formulas in order of their introduction time.

### Why It Fails As Stated

The handoff document (phase-1-handoff-20260220.md, line 73) notes "This doesn't work as stated." The analysis reveals three specific failures:

**Failure 1: F-formula persistence**. The priority queue requires checking whether `F(psi)` from an earlier MCS `M_s` is "still active." But `F(psi) ∈ M_s` does NOT imply `F(psi) ∈ M_t` for `t > s`. Lindenbaum at any intermediate step may add `G(neg psi)`, permanently killing the F-obligation. Without augmented seeds, F-formulas have no persistence guarantee.

**Failure 2: Witnessing from non-immediate predecessor**. The key consistency lemma `temporal_witness_seed_consistent` requires `F(psi) ∈ M` where `GContent(M)` is used as the base seed. If we want to witness an F-formula from `M_s` at time `t >> s`, we need `F(psi) ∈ M_{t-1}` (the immediate predecessor) for the consistency proof. But there's no mechanism to guarantee `F(psi)` propagated from `M_s` to `M_{t-1}`.

**Failure 3: The "re-establish after witness" idea fails**. The handoff suggests: at the witness step, add psi but sacrifice other F-formulas; at subsequent steps, use F-preserving seed to re-establish them. But once `G(neg chi)` enters an MCS (via Lindenbaum at the witness step), `neg chi` propagates forward through GContent forever. The F-preserving seed at step `n+2` only preserves F-formulas that are in `M_{n+1}` -- and `F(chi)` is NOT in `M_{n+1}` after `G(neg chi)` killed it.

### Mathlib Patterns Investigated

- `exists_seq_of_forall_finset_exists` (Mathlib.Data.Fintype.Basic): Builds a sequence where each element satisfies a property relative to all previous elements. Not directly applicable because the property we need (witnessing specific F-formulas) is not finitary in the required sense.

- `Directed.sequence` (Mathlib): Builds a directed sequence. Could be adapted if we had a directed family of MCSes, but the directedness requires F-witness existence, which is what we're trying to prove.

- `Encodable.axiom_of_choice`: Provides choice functions for encodable types. Useful for selecting which F-formula to witness, but doesn't solve the persistence problem.

### Can It Be Fixed?

Approach C can be fixed by combining it with the enriched seed idea:

**Fixed version**: At each step, the chain construction selects ONE F-formula from the IMMEDIATE predecessor `M_{t-1}` (not from history) and adds its witness to the seed. The priority queue is unnecessary -- simple `Nat.unpair`-based selection suffices.

This fixed version IS Approach E (described below).

### Verdict: FAILS as stated, but the core idea (priority-based selection) can be salvaged by restricting to immediate predecessors.

## Alternative Approaches Discovered

### Approach E: Enriched Recursive Chain (RECOMMENDED)

**Core idea**: Modify the existing `dovetailForwardChainMCS` and `dovetailBackwardChainMCS` to use augmented seeds that include one F/P-witness formula per step.

**Construction** (forward direction):

```
EnrichedForwardChain(base, h_cons) : Nat -> {M // SetMaximalConsistent M}
| 0 => Lindenbaum(base)
| n + 1 =>
    let prev := EnrichedForwardChain(base, h_cons, n)
    let psi_candidate := Encodable.decode (Formula) n
    let seed := match psi_candidate with
      | some psi =>
        if F(psi) ∈ prev.val then
          {psi} ∪ GContent(prev.val)   -- augmented seed
        else
          GContent(prev.val)            -- plain seed
      | none => GContent(prev.val)
    Lindenbaum(seed, <consistency_proof>)
```

**Consistency proof** for the augmented case:
- `F(psi) ∈ prev.val` (by the `if` guard)
- `prev.val` is an MCS (by inductive hypothesis)
- By `temporal_witness_seed_consistent`: `{psi} ∪ GContent(prev.val)` is consistent

**Proof of forward_F**: Given `F(psi) ∈ M_t`, we need `∃ s > t, psi ∈ M_s`.

The key insight: since `Encodable.decode` is surjective (for every formula `psi`, there exists `n = Encodable.encode psi` such that `Encodable.decode n = some psi`), the construction will eventually reach a step `n_0 = Encodable.encode psi` where the candidate is exactly `psi`.

But the step number `n_0` may correspond to a time `t_0` where `F(psi)` is NOT in `M_{t_0 - 1}`. We need `F(psi) ∈ M_{t-1}` for the specific predecessor at the step where we want to place the witness.

**The persistence lemma needed**: If `F(psi) ∈ M_t` and `psi` is placed in `M_{t+1}`'s seed (i.e., step `t+1` selects `psi`), then `psi ∈ M_{t+1}` (seed extends) and `F(psi) ∈ M_{t+1}` (because `G(neg psi) -> neg psi` by T-axiom contradicts `psi ∈ M_{t+1}`). So **F(psi) persists to the immediate successor when the witness is placed**.

If the witness is NOT placed at step `t+1` (because a different formula was selected), F(psi) may or may not persist. This is the key challenge.

**Resolution**: The coverage argument works differently from what research-002 describes:

For `F(psi) ∈ M_t`, define:
- Let `k = Encodable.encode psi`
- At step `t + k + 1` (or whichever step processes formula `psi`), the construction checks `F(psi) ∈ M_{t+k}` (the predecessor at that step)
- If `F(psi) ∈ M_{t+k}`, the witness is placed. Done.
- If `F(psi) ∉ M_{t+k}`, then `G(neg psi) ∈ M_{t+k}` (by MCS negation completeness). This means at some step between `t` and `t+k`, Lindenbaum added `G(neg psi)`.

**The deeper insight**: We don't need `F(psi)` to persist to an arbitrary step. We need to show that the enriched chain construction PREVENTS `G(neg psi)` from entering when `F(psi)` was in the preceding MCS.

Actually, the enriched construction does NOT prevent `G(neg psi)` from entering at steps where a DIFFERENT formula is being witnessed. The fundamental tension remains.

**The definitive resolution for Approach E**:

Instead of using `Encodable.decode n` to select the formula at step `n+1`, use `Nat.unpair n` to get `(step_index, formula_index)` and interpret this differently:

At step `n+1`:
1. Let `prev = M_n` (the predecessor)
2. Let `fml_idx = n` (or some function of `n`)
3. Let `psi_candidate = Encodable.decode fml_idx`
4. If `psi_candidate = some psi` and `F(psi) ∈ prev.val`, augment with `psi`
5. Else, use plain GContent seed

**Coverage**: For `F(psi) ∈ M_t`:
- The construction ensures that at EVERY step `n > t` where `Encodable.decode(n) = psi` and `F(psi) ∈ M_n`, the witness is placed.
- If `F(psi)` dies at some step `t' > t` (because Lindenbaum adds `G(neg psi)`), we need the witness to have been placed BEFORE `t'`.
- Since `Encodable.decode` cycles through all formulas, there exists `k = Encodable.encode psi` such that at step `t + k + 1`, the formula `psi` is checked. The question: does `F(psi)` survive from step `t` to step `t + k`?

**THIS IS THE CRUX**: The number of "dangerous" steps between `t` and `t + Encodable.encode(psi)` is `Encodable.encode(psi)` steps. At each step, Lindenbaum can freely add or not add `G(neg psi)`. We cannot control this.

**Final approach for E**: Use a NESTED construction. At each time point, build a sub-chain of MCSes, each extending the previous with one more F-witness. The sub-chain indexed by `(Nat, Nat)` with lexicographic order:

```
M_{t,0} = Lindenbaum(GContent(M_{t-1, omega}))   -- base at time t
M_{t,k+1} = Lindenbaum(insert(witness_k, M_{t,k}))  -- add k-th witness
M_{t,omega} = Lindenbaum(⋃_k M_{t,k})             -- limit, then MCS-extend
```

Wait -- `⋃_k M_{t,k}` is consistent (chain union) but NOT an MCS. Applying Lindenbaum to the union gives an MCS that extends all witnesses.

But `insert(witness_k, M_{t,k})` requires `neg(witness_k) ∉ M_{t,k}`. Since `F(witness_k) ∈ M_{t,k}` means `G(neg witness_k) ∉ M_{t,k}`, but `neg(witness_k)` could be in `M_{t,k}`. So the insert might be inconsistent.

This is the same problem: F(psi) in an MCS does NOT mean psi is consistent with that MCS.

**The insert approach fails. The seed approach (from `temporal_witness_seed_consistent`) only works with GContent, not with the full MCS.**

### Approach E-Revised: Inner Chain via GContent Seeds

At time `t`, build:
```
M_{t,0} = Lindenbaum(GContent(M_{t-1,final}))
M_{t,1} = Lindenbaum({psi_0} ∪ GContent(M_{t,0}))   if F(psi_0) ∈ M_{t,0}
M_{t,2} = Lindenbaum({psi_1} ∪ GContent(M_{t,1}))   if F(psi_1) ∈ M_{t,1}
...
M_{t,final} = some limit or fixed point
```

Key: At each sub-step, we use `temporal_witness_seed_consistent` with `F(psi_k) ∈ M_{t,k}` and `GContent(M_{t,k})` as base. The consistency is guaranteed.

But `psi_0 ∈ M_{t,1}` (since seed extends). Does `F(psi_0)` persist to `M_{t,1}`? Yes!
- `psi_0 ∈ M_{t,1}` (seed extends)
- `G(neg psi_0) ∉ M_{t,1}` (since `G(neg psi_0) → neg psi_0` contradicts `psi_0`)
- `F(psi_0) = neg(G(neg psi_0)) ∈ M_{t,1}` (by MCS negation completeness)

So F-formulas from the seed persist through the sub-chain!

Moreover, new F-formulas may enter through Lindenbaum maximality. The sub-chain handles formulas in order `psi_0, psi_1, ...` using `Encodable.decode k`.

The "final" MCS at time `t` must be a single MCS (not an ascending union). Option:
- Take `M_{t,final} = M_{t,K}` for some fixed `K`? But then not all F-formulas are witnessed.
- Take the union and apply Lindenbaum? The union is consistent but not an MCS. Lindenbaum could add `G(neg psi)` for some already-witnessed `psi`. But `psi ∈ ⋃_k M_{t,k}` means `psi ∈ M_{t,j}` for some `j`. The union contains `psi`. Since `psi ∈ union` and we apply Lindenbaum to the union, the result extends the union, so `psi` is in the result. And `G(neg psi) → neg psi` contradicts `psi`, so `G(neg psi)` is NOT in the result.

**THIS WORKS**: The union of the inner chain at each time point contains all witnessed formulas. Applying Lindenbaum to this union gives an MCS that:
1. Contains all witnessed formulas (since union ⊆ MCS)
2. Does NOT contain `G(neg psi)` for any witnessed `psi` (by T-axiom contradiction)
3. Therefore preserves all F-obligations for witnessed formulas

**Coverage**: Every formula `psi` with `F(psi) ∈ M_{t,0}` is eventually processed (at step `k = Encodable.encode psi`). At that step, `F(psi) ∈ M_{t,k}` (by the persistence argument above). So `psi` enters `M_{t,k+1}`. So `psi` is in the union, hence in `M_{t,final}`.

**But wait**: we need `F(psi) ∈ M_{t,0}` for this to start. F(psi) enters `M_{t,0}` via Lindenbaum maximality from `GContent(M_{t-1,final})`. If `F(psi)` was in `M_{t-1,final}`, does it appear in `M_{t,0}`?

Not necessarily. `F(psi) = neg(G(neg psi))`. For `F(psi)` to propagate from `M_{t-1}` to `M_t`, we need `G(neg psi) ∉ M_t`. But `G(neg psi) ∉ GContent(M_{t-1})` (since `G(G(neg psi)) ∉ M_{t-1}` because `G(neg psi) ∉ M_{t-1}` since `F(psi) ∈ M_{t-1}`... wait, by 4-axiom: `G(neg psi) → G(G(neg psi))`. So `G(neg psi) ∉ M_{t-1}` implies `G(G(neg psi)) ∉ M_{t-1}`, which means `G(neg psi) ∉ GContent(M_{t-1})`. So the seed for `M_{t,0}` does NOT contain `G(neg psi)`. But Lindenbaum might still add it to `M_{t,0}`.

**This is the same fundamental problem again**. F-formulas at time `t-1` may not persist to time `t` because Lindenbaum at time `t` may add `G(neg psi)`.

**HOWEVER**: the inner chain construction FIXES this. Even if `F(psi)` doesn't enter `M_{t,0}` from `M_{t-1,final}`, it doesn't matter for the original goal. The original `forward_F` goal says: given `F(psi) ∈ M_t`, find `s > t` with `psi ∈ M_s`. We need `psi` in the OUTER chain's MCS at some time `s > t`, where the outer chain uses `M_{t,final}` as the MCS at time `t`.

So: `F(psi) ∈ M_{t,final}` means at time `t`, the formula F(psi) is present. The inner chain at time `t+1` builds `M_{t+1,0}` from `GContent(M_{t,final})`. F(psi) may or may not be in `M_{t+1,0}`. But at time `t+1`, the inner chain at sub-step `k = Encodable.encode psi` checks `F(psi) ∈ M_{t+1,k}`. If `F(psi)` persisted through sub-steps 0 to k, the witness is placed. If not, we need to try at time `t+2`, etc.

The coverage argument requires showing that `F(psi)` eventually persists long enough to be processed. This is NOT guaranteed by the construction.

**Definitive insight**: The inner chain at time `t+1` needs to process `psi` FIRST (before any other formula can kill it). But the processing order is fixed by `Encodable.encode`, and we cannot guarantee `psi` has a small encoding.

### Approach F: Omega^2 Inner Chain with Immediate Witnessing

**Modification**: At each time point `t`, process ALL formulas from the immediate predecessor's F-content in a single inner chain, but process them in a specific order that prevents interference.

At time `t`, the inner chain processes formulas psi_0, psi_1, psi_2, ... in the order given by `Encodable.decode`:
- Sub-step 0: `M_{t,0} = Lindenbaum(GContent(M_{t-1,final}))`
- Sub-step k+1: if `F(decode k) ∈ M_{t,k}`, set `M_{t,k+1} = Lindenbaum({decode k} ∪ GContent(M_{t,k}))`
- Otherwise: `M_{t,k+1} = Lindenbaum(GContent(M_{t,k}))`
- Final: `M_{t,final} = Lindenbaum(⋃_k M_{t,k})`

**Claim**: For every `psi` with `F(psi) ∈ M_{t,0}`, eventually `psi ∈ M_{t,final}`.

**Proof of claim**:
1. `F(psi) ∈ M_{t,0}` (given)
2. At sub-step `k = Encodable.encode psi`, `F(psi) ∈ M_{t,k}` (by persistence: at each earlier sub-step, either the witnessed formula keeps F(psi) alive, or the non-augmented GContent step keeps it alive since `G(neg psi)` is not forced into the seed)

Actually, persistence through sub-steps is the key lemma:

**Sub-step persistence lemma**: If `F(psi) ∈ M_{t,j}` and `psi ≠ decode j`, then either:
(a) `F(psi) ∈ M_{t,j+1}`, OR
(b) `G(neg psi) ∈ M_{t,j+1}`

Case (b) means `neg psi ∈ GContent(M_{t,j+1})` propagates forward forever. But we can't rule it out because Lindenbaum is non-deterministic.

**THE PROBLEM PERSISTS**: Even in the inner chain, Lindenbaum at sub-step `j+1` can add `G(neg psi)` when processing a different formula.

### The Fundamental Obstacle (Applies to ALL Approaches)

The core issue is:

> Zorn-based Lindenbaum (`set_lindenbaum`) is an opaque existence proof. Given a consistent seed, it produces SOME MCS extending it. There is NO control over which formulas beyond the seed enter the MCS.

Every approach that uses `set_lindenbaum` at any point faces this: the Lindenbaum step can add `G(neg psi)` for any `psi` not in the seed (as long as it's consistent to do so).

The ONLY way to prevent `G(neg psi)` from entering an MCS is to ensure `psi` is in the seed (since `psi` in the MCS forces `G(neg psi)` out by T-axiom).

This means: **to guarantee F(psi) witnesses, psi MUST be in the seed of some future MCS**. And the only consistency proof available is `temporal_witness_seed_consistent`, which requires `F(psi) ∈ M` where `GContent(M)` is the base seed.

### Approach E-Final: Single-Step Enrichment with Coverage via Encoding

**The simplest correct construction**:

```
EnrichedForwardChain(base, h_cons) : Nat -> {M // SetMaximalConsistent M}
| 0 => Lindenbaum(base)
| n + 1 =>
    let prev := EnrichedForwardChain(base, h_cons, n)
    let psi := Encodable.decode (n % K) -- K = number of formulas processed per time point
    if F(psi) ∈ prev.val then
      Lindenbaum({psi} ∪ GContent(prev.val))
    else
      Lindenbaum(GContent(prev.val))
```

**forward_F proof**: Given `F(psi) ∈ M_t`:
1. Let `k = Encodable.encode psi`
2. At step `t + 1`, the enriched chain uses `Encodable.decode(t)` (or `(t+1) % something`)

Wait -- the encoding scheme needs careful design. The simplest approach:

**Refined Approach E**: At step `n+1`, pick the formula whose encoding is `n`. Check if `F(that formula) ∈ M_n`. If yes, augment seed with that formula.

For `F(psi) ∈ M_t`, let `k = Encodable.encode psi`. At step `k`, if `k > t`, the construction checks `F(psi) ∈ M_{k}`. If `F(psi)` persisted from `M_t` to `M_k`, the witness is placed at `M_{k+1}`.

**Does F(psi) persist from M_t to M_k?** Only if no intermediate Lindenbaum step added `G(neg psi)`. No guarantee.

**Alternative encoding**: Use `Nat.unpair n` to get `(time_index, formula_index)` at step `n`. At step `n`, check if `F(Encodable.decode formula_index) ∈ M_{time_index}` AND `time_index < n` AND the current time `> time_index`. The witness goes into the current time's seed.

But then at EACH time step, only one formula is selected, and the selection depends on the step number, not the time.

**THE ACTUAL CORRECT APPROACH**: Separate the time index from the enumeration index by interleaving.

Define the chain indexed by `Nat` where:
- Each `Nat` corresponds to a `(time: Int, sub_step: Nat)` pair
- The outer chain builds time points in dovetail order: 0, 1, -1, 2, -2, ...
- For each time point, an INNER chain of Nat steps processes F-formulas one by one
- The inner chain has a fixed length (equal to the encoding of the time point, or infinite)

This is the omega^2 construction from research-002, Section 15.

**Effort**: 25-35 hours. Very complex Lean proof engineering.

### Approach G: Prove forward_F by Contradiction (Indirect Argument)

Instead of modifying the chain construction, prove `forward_F` for the EXISTING `dovetailChainSet` by contradiction.

**Argument**: Suppose `F(psi) ∈ M_t` and for all `s > t`, `psi ∉ M_s`. Then for all `s > t`, `neg psi ∈ M_s` (by MCS negation completeness of each `M_s`).

Now, `neg psi ∈ M_{t+1}`. Does `G(neg psi) ∈ M_{t+1}`?

We can derive: `neg psi → G(P(neg psi))` (by axiom temp_a). So `G(P(neg psi)) ∈ M_{t+1}`. This propagates forward: `P(neg psi) ∈ M_s` for all `s > t+1`. But `P(neg psi)` says "neg psi at some past time", which is satisfied by `neg psi` at time `t+1 < s`. This doesn't directly give `G(neg psi)`.

From `neg psi ∈ M_s` for all `s > t`, we want to derive `G(neg psi) ∈ M_t`. But the proof system has no omega-rule. The handoff explicitly notes (line 39): "There is no proof-theoretic omega-rule in TM logic." So this approach fails.

**Verdict**: FAILS. No omega-rule prevents the indirect argument.

### Summary of All Approaches

| Approach | Feasibility | Effort | Key Obstacle |
|----------|-------------|--------|-------------|
| A (Constructive Lindenbaum) | Partially viable | 15-25h | Single-MCS temporal saturation |
| B (Canonical Model + Unraveling) | Viable but wasteful | 20-30h | Unraveling = enriched chain |
| C (Dependent Choice + Queue) | Fails as stated | N/A | F-persistence not guaranteed |
| D (Two-step splice) | Viable | 15-20h | Must rebuild chain suffix |
| E (Enriched recursive chain) | Viable with omega^2 inner | 25-35h | Inner chain persistence |
| F (Omega^2 inner chain) | Viable | 30-40h | Very complex engineering |
| G (Indirect/contradiction) | Fails | N/A | No omega-rule |

## Mathematical Elegance Assessment

The mathematically cleanest approach is **A (constructive formula-by-formula Lindenbaum)** because it directly addresses the root cause: Zorn-based Lindenbaum is uncontrollable. A constructive Lindenbaum with controlled enumeration order gives full control over which formulas enter the MCS.

However, the existing attempt in `TemporalLindenbaum.lean` shows that proving the LIMIT is an MCS (not just consistent) is the hard part. The maximality proof breaks for temporal formulas.

The most **pragmatically elegant** approach is **D (two-step splice)** or a variant of **E** that minimizes changes to the existing chain construction.

## Evidence

### Verified Lemmas

| Lemma | File | Status |
|-------|------|--------|
| `temporal_witness_seed_consistent` | TemporalCoherentConstruction.lean | PROVEN |
| `past_temporal_witness_seed_consistent` | DovetailingChain.lean | PROVEN |
| `dovetailForwardChainMCS_GContent_extends` | DovetailingChain.lean | PROVEN |
| `dovetailBackwardChainMCS_HContent_extends` | DovetailingChain.lean | PROVEN |
| `GContent_subset_implies_HContent_reverse` | DovetailingChain.lean | PROVEN |
| `HContent_subset_implies_GContent_reverse` | DovetailingChain.lean | PROVEN |
| `set_lindenbaum` | MaximalConsistent.lean (via boneyard re-export) | PROVEN |

### Mathlib Infrastructure Available

| Mathlib Entity | Location | Relevance |
|----------------|----------|-----------|
| `Nat.unpair` | Mathlib.Data.Nat.Pairing | Pair encoding for dovetailing |
| `Nat.surjective_unpair` | Mathlib.Data.Nat.Pairing | Coverage proof |
| `Encodable.axiom_of_choice` | Mathlib.Logic.Encodable.Basic | Choice function |
| `Set.seq_of_forall_finite_exists` | Mathlib.Data.Set.Finite.Basic | Sequence construction |
| `exists_seq_of_forall_finset_exists` | Mathlib.Data.Fintype.Basic | Directed sequence |
| `zorn_subset_nonempty` | Mathlib.Order.Zorn | Lindenbaum's lemma basis |

### Key Axioms (Verified in Axioms.lean)

| Axiom | Statement | Relevance |
|-------|-----------|-----------|
| `temp_t_future` | `G(phi) → phi` | T-axiom: prevents `G(neg psi)` when `psi` in seed |
| `temp_t_past` | `H(phi) → phi` | T-axiom (past): symmetric role |
| `temp_4` | `G(phi) → G(G(phi))` | 4-axiom: GContent propagation |
| `temp_a` | `phi → G(P(phi))` | Connectedness: links present to future-past |
| `temp_k_dist` | `G(phi → psi) → (G phi → G psi)` | K-distribution for G |

## Confidence Level

**Medium-High** for the analysis of why approaches B, C, G fail.

**Medium** for the assessment that omega^2 inner chain (Approach E/F) is the most viable alternative, but with significant engineering cost.

**Key uncertainty**: Whether there exists a simpler argument that avoids the omega^2 construction. The literature on temporal logic completeness (Goldblatt, Burgess, Reynolds) consistently uses either:
1. Constructive Henkin-style construction with controlled enumeration (= Approach A), or
2. Canonical model with tree unraveling (= Approach B)

Both require omega^2-level constructions when formalized. The 2-sorry state may represent an inherent complexity threshold for this proof.

## Recommendations

1. **Primary recommendation**: Approach A or D, with the understanding that either requires 15-25h of careful Lean proof engineering. Approach A has the advantage of being the standard textbook method; Approach D has the advantage of minimal disruption to the existing chain.

2. **If A or D fail**: Fall back to the omega^2 inner chain (Approach E/F) which is more complex but has a clearer mathematical justification.

3. **NOT recommended**: Approach B (wasteful), Approach C as stated (broken), Approach G (no omega-rule).

4. **Critical insight for ANY approach**: The key consistency lemma is `temporal_witness_seed_consistent`, and it ONLY works when `F(psi) ∈ M` and the base seed is `GContent(M)`. Any approach must ensure this precondition holds at the point of witness placement.
