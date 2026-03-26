# Cross-Chain F/P Witness Propagation: Mathematical Structure Analysis

## Key Findings

### The Two Sorry Locations

**Sorry 1 (line 3892, `forward_F`, `negSucc k` case)**:
When `F(psi) ∈ restricted_succ_chain_fam phi seed (Int.negSucc k)` (i.e., F(psi) is in `restricted_backward_chain phi seed (k+1)`), we need to find `m : Int` with `m > Int.negSucc k` and `psi ∈ restricted_succ_chain_fam phi seed m`.

The critical observation: the witness `m` may need to be a **non-negative integer** (in the forward chain), even though F(psi) is in the backward chain. This is the "cross-chain propagation" case.

**Sorry 2 (line 3917, `backward_P`, `ofNat (k+1)` case)**:
When `P(psi) ∈ restricted_succ_chain_fam phi seed (Int.ofNat (k+1))` (i.e., P(psi) is in `restricted_forward_chain phi seed (k+1)`), we need `m : Int` with `m < Int.ofNat (k+1)` and `psi ∈ restricted_succ_chain_fam phi seed m`.

Again the witness `m` may be a **non-positive integer** (in the backward chain), even though P(psi) is in the forward chain.

---

## Mathematical Structure Analysis

### 1. The Chain Topology

The `restricted_succ_chain_fam` is indexed by integers:
- **Negative positions** `Int.negSucc k` = `-(k+1)` → `restricted_backward_chain phi seed (k+1)`
- **Non-negative positions** `Int.ofNat k` → `restricted_forward_chain phi seed k`
- **Position 0**: Both `restricted_forward_chain phi seed 0 = restricted_backward_chain phi seed 0 = seed.world`

The Succ relation flows **left to right** (increasing integer direction):
- `Succ (backward_chain n+1) (backward_chain n)` (backward chain: Succ goes toward 0)
- `Succ (forward_chain n) (forward_chain n+1)` (forward chain: Succ goes away from 0)

This means the combined chain is a **bi-infinite discrete line**: `... -2, -1, 0, 1, 2, ...` with Succ always pointing rightward.

### 2. The Succ Relation and F-Content Flow

`Succ u v` requires: `f_content u ⊆ v ∪ f_content v`

This means: if `F(psi) ∈ u`, then at the next position `v`, either `psi ∈ v` (resolved) or `F(psi) ∈ v` (deferred forward). F-obligations propagate **rightward** in the chain.

Symmetrically, the Succ relation for the backward chain means: if `P(psi) ∈ v`, then at the prior position `u` (with `Succ u v`), either `psi ∈ u` or `P(psi) ∈ u`. P-obligations propagate **leftward** in the chain.

### 3. F-Witness in the Backward Chain (Sorry 1)

When `F(psi) ∈ backward_chain(k+1)` (at position `-(k+1)`):

The `restricted_forward_chain_forward_F` theorem handles the pure forward chain case (F in forward chain → witness in forward chain). No such theorem exists for the backward chain case.

**Key issue**: The backward chain is built by `constrained_predecessor_restricted`. The seed for each predecessor contains:
- `h_content(u)` = H-formulas from the current world
- `pastDeferralDisjunctions(u)` = past deferral disjunctions
- `f_step_blocking_formulas_restricted phi u` = blocking formulas to prevent F from escaping deferralClosure

The `f_step_blocking_formulas_restricted` actively **blocks F-obligations** in the predecessor. Specifically, for any `chi ∈ u` with `F(chi) ∉ u`, it adds `G(¬chi)` to the seed. This means F-witnesses for formulas in the backward chain are **suppressed** unless they exist at the current level.

However, `F(psi) ∈ backward_chain(k+1)` is still possible when `psi ∈ deferralClosure` and `F(psi) ∈ deferralClosure`, because the backward chain elements are `DeferralRestrictedMCS`, and the Succ relation flowing forward (backward_chain n+1 → backward_chain n) still requires `f_content(backward_chain n+1) ⊆ backward_chain(n) ∪ f_content(backward_chain n)`.

**The cross-chain mechanism**: If `F(psi) ∈ backward_chain(k+1)`, by Succ:
- Either `psi ∈ backward_chain(k)` (resolved at position `-(k)`)
- Or `F(psi) ∈ backward_chain(k)` (deferred to position `-(k)`)

By iterating this, F-obligations either resolve at some negative position or propagate all the way to position 0 (the seed). At position 0, we have the seed MCS which contains both F_top and P_top. If `F(psi) ∈ seed.world`, then since the forward chain starts from seed:
- `F(psi) ∈ forward_chain(0) = seed.world`
- By `restricted_forward_chain_forward_F`, there exists `m > 0` with `psi ∈ forward_chain(m)`

**The propagation argument**: F-obligations in the backward chain must either resolve within the backward chain or propagate through position 0 into the forward chain. The boundedness property (`deferral_restricted_mcs_F_bounded`) guarantees that F-iteration depth is bounded at each position, so the propagation eventually terminates.

**Crucial structural property**: The DeferralRestrictedMCS property ensures F-nesting is bounded at each world. This means `iter_F d psi ∈ backward_chain(k+1)` for some maximal `d`, and there exists `m > k+1` (as a natural number into the backward chain) or a crossing to the forward chain where psi resolves.

### 4. P-Witness in the Forward Chain (Sorry 2)

When `P(psi) ∈ forward_chain(k+1)`:

The forward chain is built by `constrained_successor_restricted`. Its seed contains:
- `g_content(u)` = G-formulas from current world
- `deferralDisjunctions(u)` = future deferral disjunctions
- `p_step_blocking_formulas_restricted phi u` = blocking formulas

The `p_step_blocking_formulas_restricted` blocks P-obligations that would leave `deferralClosure`. For `P(psi) ∈ deferralClosure`, either `psi ∈ u` (resolved) or `H(¬psi) ∈` the seed.

**The cross-chain mechanism**: If `P(psi) ∈ forward_chain(k+1)`, by the Succ relation `Succ(forward_chain k, forward_chain k+1)`:
- We need to trace P backwards, but the Succ relation only flows rightward
- The relevant backward property comes from `h_content`: `H(chi) ∈ u → chi ∈ successor`
- The `p_content` flow: `p_content(forward_chain(n+1)) ⊆ forward_chain(n) ∪ p_content(forward_chain(n))`

This is `restricted_forward_chain_p_step`. By this property, P-obligations in the forward chain propagate leftward through the forward chain. If `P(psi) ∈ forward_chain(k+1)`, it either resolves at `forward_chain(k)` or defers to `P(psi) ∈ forward_chain(k)`. Iterating, P-obligations propagate to position 0. At position 0 = seed.world:
- `P(psi) ∈ seed.world` which is also `backward_chain(0)`
- By `restricted_backward_chain_backward_P`, there exists `m > 0` with `psi ∈ backward_chain(m)` (i.e., at position `-(m)`)

### 5. Seed MCS Properties Enabling Cross-Chain Propagation

The seed MCS (`DeferralRestrictedSerialMCS`) must contain **both F_top and P_top**. This is the "serial" condition:

- `F_top = F(¬⊥) ∈ seed.world` ensures the forward chain can be built (future is non-empty)
- `P_top = P(¬⊥) ∈ seed.world` ensures the backward chain can be built (past is non-empty)
- Both chains share position 0 (the seed), creating the essential **bridge**

The cross-chain transfer works precisely because position 0 is both:
- `forward_chain(0)` (the start of the forward chain)
- `backward_chain(0)` (the start of the backward chain)

F-obligations that propagate all the way left through the backward chain reach the seed at position 0, which is also the position 0 of the forward chain, where `restricted_forward_chain_forward_F` can be applied.

### 6. Consistency Argument for Cross-Chain Witnesses

The argument for why cross-chain witnesses must exist:

**For Sorry 1** (F in backward chain → witness exists):
1. `F(psi) ∈ backward_chain(k+1)` with `F(psi) ∈ deferralClosure phi`
2. By F-boundedness (`deferral_restricted_mcs_F_bounded`), there is a maximal d such that `iter_F d psi ∈ backward_chain(k+1)` but `iter_F (d+1) psi ∉ backward_chain(k+1)`
3. By the Succ relation and p_step propagation, `iter_F d psi` either resolves within the backward chain (witness found) or propagates to position 0
4. At position 0 = forward_chain(0), `iter_F d psi ∈ forward_chain(0)` means by `restricted_forward_chain_iter_F_witness` there exists `m > 0` with `psi ∈ forward_chain(m)`
5. This gives the cross-chain witness at integer position `Int.ofNat m > 0 > Int.negSucc k`

**For Sorry 2** (P in forward chain → witness exists):
The symmetric argument using `restricted_forward_chain_p_step` and `restricted_backward_chain_backward_P`.

---

## Recommended Approach

### Approach: Propagation to Seed + Cross-Chain Transfer

The proof strategy for both sorries follows the same pattern:

**Step 1**: Use F-boundedness (or P-boundedness) to find the maximal nesting depth at the starting position.

**Step 2**: Apply the step-wise propagation lemma (F-step for forward → backward, P-step for forward → backward) to track the obligation through the chain.

**Step 3**: Show that if the obligation doesn't resolve within the current chain, it propagates to position 0 (the seed).

**Step 4**: At position 0, the formula is in `forward_chain(0) = backward_chain(0) = seed.world`. Apply the existing single-chain coherence theorem for the other chain direction to get the witness.

**Step 5**: Convert the witness from a Nat index to the appropriate Int index.

### Concrete proof sketch for Sorry 1 (`forward_F`, `negSucc k` case):

```
-- h_F : F(psi) ∈ restricted_backward_chain phi seed (k+1)
-- Goal: ∃ m : Int, m > Int.negSucc k ∧ psi ∈ restricted_succ_chain_fam phi seed m

-- Use F-boundedness to get maximal depth at position k+1
have h_bounded := restricted_backward_chain_F_bounded phi seed (k+1) psi h_F
-- (Need a restricted_backward_chain_F_bounded theorem - analogous to P_bounded)

-- Apply step-wise propagation (need restricted_bounded_witness_backward version)
-- Eventually psi resolves either in backward chain or via forward chain from position 0

-- Case A: resolves at position m' within backward chain (m' > k+1)
-- → witness at Int.negSucc (m' - 1), which is > Int.negSucc k ✓

-- Case B: propagates to position 0 (seed), then F-obligation enters forward chain
-- Apply restricted_forward_chain_forward_F to get m > 0 in forward chain
-- → witness at Int.ofNat m, which is > 0 > Int.negSucc k ✓
```

**Missing infrastructure**: There is no `restricted_backward_chain_F_bounded` theorem and no corresponding `restricted_backward_bounded_witness_F` theorem. These need to be created analogously to `restricted_backward_chain_P_bounded` and `restricted_backward_bounded_witness`.

However, the `constrained_predecessor_restricted_f_step_forward` theorem (line 3370) already establishes: `f_content(predecessor) ⊆ u ∪ f_content(u)`. This is the F-step property for the backward chain direction - F-obligations in a backward chain element flow to the successor (rightward) element. This is the core mechanism needed.

The **critical gap** is that there is currently a `sorry` in `constrained_predecessor_restricted_f_step_forward` itself (line 3420, the case where `chi ∉ u` and `F(chi) ∉ u`). This sorry must also be resolved before the cross-chain sorry can be closed.

Similarly, `constrained_predecessor_restricted_g_persistence_reverse` has a sorry (line 3360). This sorry affects the Succ relation for the backward chain, which is needed for the propagation argument.

### Priority Order for Resolving Sorries

1. **`constrained_predecessor_restricted_g_persistence_reverse`** (line 3360): The G-persistence reverse property. This is needed for Succ v u to hold for the backward chain.

2. **`constrained_predecessor_restricted_f_step_forward`** (line 3420, `chi ∉ u, F(chi) ∉ u` case): The F-step for the predecessor. This establishes that F-obligations in the backward chain properly flow forward.

3. **Create `restricted_backward_chain_F_bounded`**: Analogous to `restricted_backward_chain_P_bounded`, using `deferral_restricted_mcs_F_bounded`. This should follow immediately since `DeferralRestrictedMCS` has F-boundedness.

4. **Create `restricted_backward_bounded_witness_F`**: The F-witness propagation lemma for the backward chain. Structurally mirrors `restricted_backward_bounded_witness` (the P version).

5. **Sorry 1** (line 3892): Once steps 1-4 are done, prove the cross-chain case using propagation to seed + `restricted_forward_chain_forward_F`.

6. **Sorry 2** (line 3917): Symmetric to Sorry 1, using `restricted_forward_chain_p_step` and `restricted_backward_chain_backward_P`.

---

## Confidence Level

**Mathematical correctness of the approach**: HIGH

The cross-chain propagation argument is mathematically sound. The seed at position 0 is the essential bridge connecting the two chains. F-obligations in the backward chain can propagate rightward through Succ until they either resolve within the backward chain or reach position 0, from which they enter the forward chain. The DeferralRestrictedMCS property guarantees termination via bounded F/P nesting depth.

**Feasibility of the Lean proof**: MEDIUM

The approach is clear, but requires:
1. Resolving two pre-existing sorries in `constrained_predecessor_restricted_*` theorems
2. Creating two new lemmas (`restricted_backward_chain_F_bounded`, `restricted_backward_bounded_witness_F`)
3. The termination argument for the new inductive witness lemma (similar to the existing `restricted_backward_bounded_witness` which also has a sorry in its `termination_by` section)

The existing `restricted_backward_bounded_witness` has a `sorry` in its `decreasing_by` block (line 3824), which suggests the termination argument is non-trivial. The same challenge will apply to the new F-variant. This reduces the confidence that both sorries can be resolved cleanly without additional infrastructure.

**Assessment**: The mathematical path is clear. The engineering challenge is the pre-existing sorries in the predecessor construction and the termination argument for the inductive lemma.
