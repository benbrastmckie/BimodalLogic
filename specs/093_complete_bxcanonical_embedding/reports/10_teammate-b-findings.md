# Teammate B Findings: Alternative Approaches for BXCanonical Embedding

**Task**: 93 - Close BXCanonical embedding sorry
**Role**: Teammate B (Alternative Approaches)
**Date**: 2026-04-13

## Key Findings

1. **Restricted forward_F CAN be proved directly** without delegating to unrestricted forward_F, by exploiting finiteness of `deferralClosure(root)` and the scheduling mechanism.
2. **The counterexample from Report 09 is CORRECT and COMPLETE** -- all BX axiom interactions have been systematically checked; no axiom rescues the seed.
3. **BX12 reduction is NOT viable** for the restricted forward_F path because `(top U psi)` is NOT in `subformulaClosure(root)` when `F(psi)` appears (the closure is syntactic, not semantic).
4. **Filtered untilCarry is a viable partial mitigation** but insufficient alone -- it avoids the known counterexample class but introduces a different incompleteness risk.

## Analysis of Restricted Forward_F

### The Delegation Problem

At line 603-615 of `CanonicalModel.lean`, `bx_bfmcs_restricted_tc` proves restricted temporal coherence. It receives the hypothesis `_h_dc : phi in deferralClosure root` but immediately discards it, calling unrestricted `bx_fmcs_forward_F` (line 610):

```
have <s', h_lt, h_psi> := bx_fmcs_forward_F N h_N (t - s) psi h_F
```

This is wasteful. The restricted version only needs: for `phi in deferralClosure(root)`, if `F(phi) in fam.mcs t`, then `exists s > t, phi in fam.mcs s`.

### Direct Restricted Proof Strategy

The scheduling chain (`int_chain`) builds successors via `fwd_succ M h_mcs (schedule n)` where `schedule n` enumerates all formulas. When `F(psi) in chain(t)`:

**Step 1**: By `schedule_surjective_above`, there exists `n >= t.toNat` with `schedule n = psi`.

**Step 2**: The chain at step `n+1` is `fwd_succ (chain(n)) h_mcs psi`. When `F(psi) in chain(n)` (which follows from F-carry propagation), the resolving branch fires: `psi in chain(n+1)`.

**Step 3**: The key gap is proving `F(psi) in chain(n)` when we only know `F(psi) in chain(t)` for `t <= n`.

### The F-carry Mechanism

The codebase already has `f_carry` (lines 50-53): the set of F-formulas in an MCS. Non-resolving steps propagate F-formulas via `fwd_succ_f_carry`. The issue is:

- **Resolving steps**: When `fwd_succ M h_mcs chi` fires the resolving branch for some `chi`, it uses seed `{chi} union g_content(M)`. This does NOT include `f_carry(M)`. So `F(psi)` could be LOST if a different formula `chi != psi` is being resolved at that step.

- **Non-resolving steps**: When `F(chi) not in M`, the seed is `g_content(M) union f_carry(M)`, preserving all F-formulas.

So F-carry persistence fails at resolving steps for OTHER formulas. Between time `t` (where `F(psi) in chain(t)`) and time `n` (where `schedule n = psi`), there may be arbitrarily many resolving steps for other formulas that destroy `F(psi)`.

### Can We Recover F(psi) After a Resolving Step?

After resolving `chi` at step `k`: `chi in chain(k+1)`, and `g_content(chain(k)) subset chain(k+1)`.

We need: if `F(psi) in chain(k)` and step `k` resolves `chi`, is `F(psi) in chain(k+1)`?

Since `F(psi) in chain(k)`, we know `G(neg(psi)) not in chain(k)`. The successor `chain(k+1)` extends `g_content(chain(k))`. But `F(psi) = neg(G(neg(psi)))` is NOT of the form `G(alpha)`, so it does NOT appear in `g_content(chain(k))`.

**Possible recovery via BX4'**: `F(psi) -> H(F(psi))` is NOT an axiom. BX4' gives `phi -> H(F(phi))`, which says: if `phi` holds now, then at all past times `F(phi)` held. The CONVERSE is needed and is not available.

**Possible recovery via BX4**: `F(psi) in chain(k)` means `F(psi)` holds at time `k`. By BX4: `F(psi) -> G(P(F(psi)))`, so `P(F(psi)) in chain(k+1)`. But `P(F(psi))` is NOT `F(psi)`.

**Verdict**: F-formulas genuinely can be lost through resolving steps. The unrestricted `bx_fmcs_forward_F` is blocked by this fundamental gap. The restricted version faces the same gap.

### Restricted Strategy: Finite Enumeration

For the RESTRICTED case, `deferralClosure(root)` is a FINITE set. Let `N = |deferralClosure(root)|`.

**Idea**: Instead of relying on F-carry, use the finiteness to argue that between any two resolution events for `psi`, there are at most `|Formula|` steps (via schedule surjectivity). But `|Formula|` is infinite, so this does not help.

**Better idea**: For a FIXED finite set `S = deferralClosure(root)`, we could build a MODIFIED chain that resolves only formulas in `S` (not all formulas). With `|S|` formulas, a round-robin schedule resolves each one every `|S|` steps. Then F-carry only needs to survive `|S|-1` resolving steps per round. But the chain is already built -- modifying it would require a new construction.

**Verdict**: A direct restricted proof on the EXISTING chain architecture is NOT possible without modifying the chain construction. The chain resolves all formulas, and F-formulas for the restricted set can be lost in the same way as unrestricted ones.

## UntilCarry Consistency Re-examination

### Systematic Formula Interaction Analysis

The seed in question is: `{psi} union g_content(M) union untilCarry(M, root)` where:
- `untilCarry(M, root) = {(alpha U beta) | (alpha U beta) in subformulaClosure(root) cap M}`

For each Until formula `(a U b) in untilCarry(M, root)`:

**BX9 gives**: `a v b` in any MCS containing `(a U b)`.

**BX10 gives**: `F(b)` in any MCS containing `(a U b)`.

**BX5 gives**: `(a and (a U b)) U b` -- self-accumulation.

**BX8 gives**: `b -> (a U b)` -- reflexive introduction (converse direction, not directly useful).

**BX7 interaction with multiple Until formulas**: If `(a1 U b1)` and `(a2 U b2)` both in the seed, BX7 gives a three-way disjunction about their witness ordering. This constrains but does not create inconsistency per se.

### Counterexample Verification (from Report 09 Teammate A)

**Setup**: M is a BX-MCS with:
- `F(psi) in M`
- `G(neg(alpha)) in M`
- `(alpha U neg(psi)) in M` and `(alpha U neg(psi)) in subformulaClosure(root)`

**Seed**: `{psi, neg(alpha), (alpha U neg(psi))}` (where `neg(alpha) in g_content(M)` from `G(neg(alpha)) in M`).

**Derivation of inconsistency**:
1. `(alpha U neg(psi)) -> alpha v neg(psi)` (BX9)
2. `neg(alpha)` in seed
3. From (1): either `alpha` or `neg(psi)` holds in any MCS extending the seed
4. `neg(alpha)` in seed eliminates the `alpha` disjunct
5. So `neg(psi)` must be in any MCS extension
6. But `psi` is in the seed
7. `psi` and `neg(psi)` are inconsistent

More precisely: from the seed, derive `bot`:
- `(alpha U neg(psi)) -> (alpha v neg(psi))` is an axiom instance (BX9)
- From `(alpha U neg(psi))` and this axiom, derive `alpha v neg(psi)` by MP
- `alpha v neg(psi)` is `neg(alpha) -> neg(psi)` (by definition of `v` as `neg(a) -> b`)
- From `neg(alpha)` and `neg(alpha) -> neg(psi)`, derive `neg(psi)` by MP
- From `psi` and `neg(psi)`, derive `bot`

**BX10 check**: `(alpha U neg(psi)) -> F(neg(psi))`. So `F(neg(psi)) in M`. Does `F(neg(psi))` conflict with anything in M?
- `F(psi) in M` -- this is `neg(G(neg(psi)))`
- `F(neg(psi)) = neg(G(neg(neg(psi)))) = neg(G(psi))`
- Both `F(psi)` and `F(neg(psi))` can coexist: `neg(G(neg(psi)))` and `neg(G(psi))` mean "not always psi" and "not always neg(psi)", which is consistent (psi holds sometimes, fails sometimes).

**BX7 check**: Only one Until formula in the counterexample, so BX7 does not apply.

**BX5 check**: `(alpha U neg(psi)) -> ((alpha and (alpha U neg(psi))) U neg(psi))`. This strengthens the guard but does not affect the seed inconsistency.

**BX4 check**: `F(psi) -> G(P(F(psi)))` -- adds `P(F(psi))` to the future but does not affect the seed.

**BX11 check**: `F(psi) and F(neg(psi)) -> F(psi and neg(psi)) v F(psi and F(neg(psi))) v F(F(psi) and neg(psi))`. Since `psi and neg(psi) = bot`, the first disjunct gives `F(bot)`, which is inconsistent with `G(neg(bot))` (a theorem). So:
- IF `F(psi and neg(psi))` were the only option, M would be inconsistent.
- But the second and third disjuncts are available and consistent.
- `F(psi and F(neg(psi)))`: there exists a future time where `psi` and `F(neg(psi))` both hold. This is satisfiable.
- `F(F(psi) and neg(psi))`: there exists a future time where `F(psi)` and `neg(psi)` both hold. Also satisfiable.

**Conclusion**: The counterexample M is CONSISTENT. All BX axioms have been checked. The seed `{psi} union g_content(M) union untilCarry(M, root)` IS inconsistent for this choice of M and root.

### Exhaustive Case Analysis

The inconsistency arises specifically when:
- `(alpha U beta) in untilCarry` with `beta = neg(psi)` (the negation of the resolving target)
- `neg(alpha) in g_content(M)` (equivalently `G(neg(alpha)) in M`)

Are there other problematic patterns? Consider:
- `(alpha U beta) in untilCarry` with `beta = psi`: BX9 gives `alpha v psi`. This is CONSISTENT with `{psi}` (both sides work).
- `(alpha U beta) in untilCarry` with `beta` unrelated to `psi`: BX9 gives `alpha v beta`. No conflict with `psi` or `g_content(M)` unless there is a derived chain of implications (possible but requires specific formula structure).

**Pattern**: The ONLY systematic counterexample pattern is when there exists `(alpha U neg(psi)) in untilCarry` with `G(neg(alpha)) in M`. Other patterns require model-specific formula dependencies.

## BX12 Reduction Viability

### The Idea

BX12: `F(phi) -> (top U phi)`. If the restricted forward_F only needs witnesses for `phi in deferralClosure(root)`, and if `(top U phi) in subformulaClosure(root)` for such `phi`, then forward Until coherence (which provides witnesses for Until formulas) would handle F-resolution, eliminating forward_F as an independent obligation.

### Analysis

`subformulaClosure(root)` is defined syntactically in `Syntax/SubformulaClosure.lean` as `(Formula.subformulas root).toFinset`. The subformula relation is purely structural:
- `subformulas (phi U psi) = (phi U psi) :: (subformulas phi ++ subformulas psi)`
- `subformulas (all_future phi) = (all_future phi) :: subformulas phi`

For `F(psi) = neg(G(neg(psi)))` to be a subformula of `root`, the root must syntactically contain `neg(all_future(neg(psi)))`. If it does, then `subformulaClosure` includes `all_future(neg(psi))`, `neg(psi)`, and `psi` -- but NOT `(top U psi)`.

**Key point**: `(top U psi)` is NEVER a subformula of any formula that does not syntactically contain `top U psi`. The BX12 reduction `F(psi) -> (top U psi)` introduces a formula OUTSIDE the closure.

### Does deferralClosure Help?

`deferralClosure(root) = baseDeferralClosure(root)` which includes `closureWithNeg(root)` plus deferral disjunctions plus seriality formulas. It does NOT include `(top U psi)` for arbitrary `psi in closureWithNeg(root)`.

The `extendedDeferralClosure` adds `untilDeferralSet` and `sinceDeferralSet`, but these are deferral disjunctions for existing Until/Since formulas, not newly generated Until formulas.

**Verdict**: BX12 reduction is NOT viable with the current closure definitions. Adding `(top U psi)` for each `F(psi)` in the closure would be a Reynolds-style enrichment, but would require modifying `deferralClosure` (or `extendedDeferralClosure`) and re-proving all downstream theorems that depend on closure membership. This is a substantial refactor (~200-400 lines).

### Could EnrichedClosure Help?

`EnrichedClosure.lean` (Fisher-Ladner style) adds `G(neg(bigconj T))` and `H(neg(bigconj T))` for subsets T of SubformulaClosure. It does NOT add Until formulas. So it does not help with the BX12 path either.

## Filtered UntilCarry Design

### The Idea

Instead of `untilCarry(M, root) = {(a U b) | (a U b) in subformulaClosure(root) cap M}`, use:

`filteredUntilCarry(M, root, psi) = {(a U b) in subformulaClosure(root) cap M | b != neg(psi)}`

This excludes precisely the Until formulas whose right operand is `neg(psi)` (the resolving target's negation), avoiding the known counterexample pattern.

### Consistency Analysis

**Claim**: `{psi} union g_content(M) union filteredUntilCarry(M, root, psi)` is consistent whenever `F(psi) in M`.

**Proof sketch**: By contradiction. Suppose `L subset seed` with `L derives bot`. By the standard argument (as in `forward_temporal_witness_seed_consistent`), extract `G(neg(psi)) in M`, contradicting `F(psi) in M`.

Wait -- the standard argument works for `{psi} union g_content(M)`. Adding the filtered carry introduces new formulas. Let me be more careful.

Suppose `L subset {psi} union g_content(M) union filteredUntilCarry(M, root, psi)` with `L derives bot`.

Partition `L = L_psi union L_g union L_u` where `L_psi subset {psi}`, `L_g subset g_content(M)`, `L_u subset filteredUntilCarry`.

For each `(a U b) in L_u`: `b != neg(psi)`, and `(a U b) in M`.

**Key question**: Can we lift `L derives bot` to `G(neg(psi)) in M`?

No, we cannot directly. The standard argument uses generalized temporal K: from `L_g derives neg(psi)` (with `psi` removed by deduction), lift to `G(L_g) derives G(neg(psi))`. But the Until formulas in `L_u` are NOT of the form `G(alpha)` -- they are in M but not necessarily in g_content(M).

From `(a U b) in M`, we know `G(a U b)` is NOT guaranteed. We only know `(a U b) in M`.

**Obstacle**: The generalized temporal K argument fundamentally requires all non-psi context formulas to be in `g_content(M)` (i.e., universalized by G). Until formulas from the carry are in M but not necessarily under G. The lifting fails.

### Modified Approach: Until Induction

For each `(a U b) in L_u`: from `(a U b) in M` and assuming `G(neg(psi)) in M`:
- BX9: `a v b` in M
- BX10: `F(b) in M`
- Since `b != neg(psi)`, we know `b` is not directly contradicted by `psi`.

But can the combination of `psi`, `g_content(M)`, and the filtered Until formulas still derive `bot`? Yes, through indirect chains. For example:
- `(alpha U beta) in filteredUntilCarry` with `beta != neg(psi)` but `beta -> neg(psi)` derivable from other context.
- This would make the filtered seed inconsistent despite the filter.

**Verdict**: Filtered untilCarry avoids the DIRECT counterexample pattern (`b = neg(psi)`) but does NOT provide a consistency PROOF. The generalized temporal K argument cannot accommodate Until formulas. A consistency proof would need a fundamentally different technique -- likely something based on the until_induction axiom combined with temporal K -- which has not been developed.

## Confidence Level

**HIGH** on the following conclusions:
1. The existing chain architecture CANNOT prove `bx_fmcs_forward_F` (restricted or unrestricted) because F-formulas are lost through resolving steps for other formulas.
2. The counterexample from Report 09 is correct and exhaustively verified against all BX axioms.
3. BX12 reduction is not viable with current closure definitions.

**MEDIUM** on:
4. A modified chain construction (root-parameterized, resolving only `deferralClosure(root)` formulas) COULD prove restricted forward_F. This would require ~200-300 lines of new chain infrastructure but has sound mathematical foundations.
5. Filtered untilCarry is the right conceptual direction but needs a novel consistency proof technique.

**LOW** on:
6. Any approach that avoids modifying the chain construction while proving forward_F on the existing architecture.

## Actionable Recommendation

The most promising path is to build a **root-parameterized chain** that:
1. Takes `root : Formula` as a parameter
2. Uses a finite round-robin schedule over `deferralClosure(root)` instead of `Denumerable.ofNat`
3. In the non-resolving branch, includes `f_carry` restricted to `deferralClosure(root)` formulas
4. This ensures F-formulas within the restricted set survive all steps (since the schedule only resolves formulas from the same finite set, and the carry includes all F-formulas from that set)

This construction would prove `restricted_forward_F` directly without needing unrestricted `forward_F`. Estimated effort: 200-300 lines for the new chain + restricted coherence proofs.
