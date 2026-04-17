# Teammate A Findings: Primary Approach Analysis (Round 32)

## Key Findings

### 1. The Irreducible Core Problem

After reading all 1,559 lines of `RootScopedChain.lean`, the 31 prior research reports, and the supporting infrastructure in `Frame.lean`, `CanonicalModel.lean`, `Quasimodel/Construction.lean`, `Quasimodel/Realization.lean`, `Bundle/TemporalCoherence.lean`, `Bundle/UntilSinceCoherence.lean`, and `Algebraic/RestrictedParametricTruthLemma.lean`, I can state the core problem with mathematical precision:

**Sorry 1** (`rr_fwd_chain_forward_F`, line 1413): The depth-0 base case of the strong induction on `f_nesting_depth`. Given `F(chi) in rr_fwd_chain(M0, sigma_list, m)` with `f_nesting_depth(chi) = 0`, prove `exists s > m, chi in rr_fwd_chain(M0, sigma_list, s)`.

The existing chain uses `enriched_fwd_step` (line 583) which calls `resolving_enriched_fwd_exists` (line 368) at resolving steps. This produces an MCS via `set_lindenbaum` whose `.choose` is unconstrained. The BX11 fold (`enriched_fwd_fold`, line 162) guarantees:
- **Disjunctive preservation**: `chi in M' OR F(chi) in M'` for each F-defective formula (via `enriched_fwd_step_preserves`, line 626)
- **At least one direct resolution**: `exists w, w in M'` (via `enriched_fwd_step_resolves_one`, line 644)

But the fold CANNOT guarantee that any SPECIFIC formula chi is directly resolved. The three-way BX11 case split (lines 185-249 of `enriched_fwd_fold`) is determined by the MCS content, and case 3 (`F(F(beta) AND chi)`) wraps the accumulated compound in F, degrading direct presence to F-protected presence. This "BX11 hijacking" (dead end 22) is semantically consistent: there exist MCS sequences where a specific formula is perpetually F-protected and never directly resolved.

### 2. Why the Perpetual Deferral Contradiction Argument Fails

Report 31 (Sections 13-17) attempted to show that the set `P = {chi in sigma_list | F(chi) in chain(m) for all m >= n AND chi not_in chain(m) for all m > n}` must be empty by contradiction. The argument was:

1. At each visit step for phi in P, `enriched_fwd_step_resolves_one` gives w in chain(v_i + 1) with w != phi.
2. w cannot be in P (since w in chain(v_i + 1) contradicts the "never present" condition).
3. So the fold always resolves a non-P formula.

The gap: this does NOT lead to a contradiction. Non-P formulas can oscillate (resolved, then F-defective again, then resolved again), providing an inexhaustible supply of "other" formulas for the fold to resolve while perpetually deferring P-members. The BX11 three-way case split in each MCS can consistently choose case 3 for P-members at every step.

### 3. The Sorry Dependency Structure

The 6 sorry sites have the following precise dependencies:

| Sorry | Line | Statement | Depends On |
|-------|------|-----------|------------|
| 1 | 1413 | `rr_fwd_chain_forward_F` depth-0 base | CORE BLOCKER |
| 2 | 1457 | `dd_fmcs_forward_F` t < 0 case | Sorry 1 + backward-to-forward F-propagation |
| 3 | 1464 | `dd_fmcs_backward_P` | Symmetric to sorry 1 for backward chain |
| 4 | 1517 | `dd_bfmcs_restricted_tc` | Sorry 1 + sorry 3 |
| 5 | 1522 | `dd_bfmcs_restricted_buc` | Step transfer property (INDEPENDENT of sorry 1) |
| 6 | 1527 | `dd_bfmcs_restricted_fuc` | Forward Until discharge (PARTIALLY INDEPENDENT) |

**Critical observation**: Sorries 5 and 6 are about Until/Since coherence, not F/P temporal coherence. They require different proof strategies.

### 4. Analysis of Sorry 5 (Backward Until/Since Coherence)

`dd_bfmcs_restricted_buc` (line 1522) requires `restricted_backward_until_since_coherent root`, which means (from `TemporalCoherence.lean:565-574`):

For each family `fam`, for each `phi U psi in subformulaClosure(root)`:
- If `exists s >= t` with `psi in fam.mcs(s)` and `phi in fam.mcs(r)` for `t <= r < s`, then `phi U psi in fam.mcs(t)`.

The existing `backward_until_from_step` (`UntilSinceCoherence.lean:111`) reduces this to a **step transfer** property:

```
h_step: forall r, (phi U psi) in fam.mcs(r + 1) -> phi in fam.mcs(r) -> (phi U psi) in fam.mcs(r)
```

**Can we prove step transfer for `dd_chain`?**

For the forward chain (t >= 0): `fam.mcs(r) = rr_fwd_chain(r)` and `fam.mcs(r+1) = enriched_fwd_step(rr_fwd_chain(r), ...)`. The step is:

Given `(phi U psi) in chain(r+1)` and `phi in chain(r)`, show `(phi U psi) in chain(r)`.

From `(phi U psi) in chain(r+1)` and `g_content(chain(r)) subset chain(r+1)`: we need to get `(phi U psi)` back into `chain(r)`. But `(phi U psi)` is NOT a G-formula, so g_content propagation goes the wrong direction (forward, not backward).

From `phi in chain(r)`: by BX8, `phi U phi in chain(r)`. But we need `phi U psi`, not `phi U phi`.

From `(phi U psi) in chain(r+1)`: by BX4', `H(F(phi U psi)) in chain(r+1)`. By backward_H of the FMCS: `F(phi U psi) in chain(r)`. By BX12 (`F_imp_top_until_mcs`): `top U (phi U psi) in chain(r)`.

Now we have `phi in chain(r)` and `top U (phi U psi) in chain(r)`. We need `phi U psi in chain(r)`.

**This requires a BX theorem**: `phi AND (top U (phi U psi)) -> phi U psi`. Under BX reflexive semantics, `top U alpha` means `exists s >= t, alpha at s` (with trivial guard). So `top U (phi U psi)` at time t means `phi U psi` holds at some future time s. Combined with `phi` at time t... this does NOT directly give `phi U psi` at time t. The Until formula at time t requires psi at some `s' >= t` with phi guarding [t, s'). Having `phi U psi` at a FUTURE time s only gives psi at `s' >= s` with phi guarding [s, s'), not [t, s').

**Step transfer appears unprovable for the current chain construction.** This is a genuine obstacle independent of sorry 1.

**Alternative for sorry 5**: Use a direct induction on `s - t` without the step transfer abstraction. Given `psi in chain(s)` and `phi in chain(r)` for `t <= r < s`:

- Base case `s = t`: `psi in chain(t)` gives `phi U psi in chain(t)` by BX8 (proved as `backward_until_reflexive`).
- Inductive case `s > t`: We have `phi in chain(t)` and (by IH) `phi U psi in chain(t+1)`. Need `phi U psi in chain(t)`.

This reduces to the same step transfer! The problem is that `phi U psi in chain(t+1)` does not propagate backward to `chain(t)` without additional chain structure.

**Viable path for sorry 5**: The step transfer IS provable if we can show:

```
(phi U psi) in chain(r+1) -> G(phi U psi) in chain(r) OR some BX axiom gives backward propagation
```

Under BX4': `(phi U psi) in chain(r+1)` gives `H(F(phi U psi)) in chain(r+1)`. By FMCS backward_H: `F(phi U psi) in chain(r)`. Now `F(phi U psi) in chain(r)` and `phi in chain(r)`. By BX5 (self-accumulation applied to Until): `phi AND F(phi U psi)` should give `phi U psi`... but BX5 is `(phi U psi) -> (phi AND (phi U psi)) U psi`, which goes the wrong way.

**Actually**: `F(phi U psi) in chain(r)` means `neg G(neg (phi U psi)) in chain(r)`. From BX12: `F(alpha) -> top U alpha`. So `top U (phi U psi) in chain(r)`. We need to go from `phi in chain(r) AND top U (phi U psi) in chain(r)` to `phi U psi in chain(r)`.

By BX7 (linear Until): `(alpha U beta) AND (gamma U delta) -> ((alpha AND gamma) U (beta AND gamma)) OR ((alpha AND gamma) U (alpha AND delta))` (one of several disjuncts). Applied to `top U (phi U psi)` and thinking of `phi` as part of another Until... this doesn't directly apply since `phi` alone is not an Until formula.

**Conclusion for sorry 5**: Step transfer for backward Until coherence appears to require either:
(a) A chain construction where `(phi U psi) in chain(r+1) AND phi in chain(r) -> (phi U psi) in chain(r)` is built into the seed (e.g., including Until formulas in the seed), or
(b) A completely different proof strategy that avoids step transfer.

### 5. Analysis of Sorry 6 (Forward Until/Since Coherence)

`dd_bfmcs_restricted_fuc` (line 1527) requires: for each `phi U psi in subformulaClosure(root)` with `phi U psi in fam.mcs(t)`, exists `s >= t` with `psi in fam.mcs(s)` and `phi in fam.mcs(r)` for `t <= r < s`.

From `phi U psi in chain(t)`:
- By BX9 (`until_elim`): `psi in chain(t) OR (phi in chain(t) AND F(phi U psi) in chain(t))`.
  - If `psi in chain(t)`: witness `s = t`, done.
  - If `phi in chain(t) AND F(phi U psi) in chain(t)`: we have F(phi U psi) in chain(t).

Now `F(phi U psi) in chain(t)` with `phi U psi in deferralClosure(root)` (by closure properties). This is an F-eventuality obligation: we need `phi U psi in chain(s)` for some `s > t` (by sorry 1/forward_F). Then at that s, recurse.

**Sorry 6 DOES depend on sorry 1** (forward_F), contrary to what I initially suggested. The forward Until coherence reduces to forward_F for Until formulas.

BUT: even given forward_F, we only get `phi U psi in chain(s)` for `s > t`. We then need to extract the guard condition: `phi in chain(r)` for `t <= r < s'` where `psi in chain(s')`. This requires induction on the chain structure.

**By BX5 (self-accumulation)**: `phi U psi in chain(t)` gives `(phi AND (phi U psi)) U psi in chain(t)`. This is a stronger Until formula. By BX9: either `psi in chain(t)` (done) or `(phi AND (phi U psi)) in chain(t) AND F((phi AND (phi U psi)) U psi) in chain(t)`.

The guard formula is now `phi AND (phi U psi)`, which includes the Until formula itself. This self-referential structure is what the quasimodel's defect-discharge mechanism is designed to handle (Construction.lean:45-52, `hintikka_step` definition).

### 6. Analysis of Sorry 2 (Forward F for t < 0)

`dd_fmcs_forward_F` at line 1457 handles the case `t < 0` (backward chain region). Given `F(psi) in dd_chain(t)` with `t < 0`:

The chain at `t < 0` is `rr_bwd_chain((-t).toNat)`. The backward chain uses `bwd_pred` which preserves `h_content` (not g_content) and `p_carry` (P-formulas, not F-formulas).

To find `s > t` with `psi in dd_chain(s)`: we need to propagate `F(psi)` from the backward region to the forward region (through M0 at position 0) and then apply forward_F.

From `F(psi) in chain(t)` with `t < 0`:
- If `G(F(psi)) in chain(t)`: then `F(psi) in chain(0) = M0` by g_content propagation, and then apply sorry 1 on the forward chain.
- If `G(F(psi)) not_in chain(t)`: `F(psi)` might not reach M0.

`G(F(psi))` is `G(neg G(neg psi))`. From `F(psi) in chain(t)`: by BX4 (`connect_future`), `G(P(F(psi))) in chain(t)`. This gives `P(F(psi)) in chain(s)` for all `s >= t`. In particular `P(F(psi)) in chain(0)`. But `P(F(psi))` gives us F(psi) at some PAST time, not at time 0.

Actually, under reflexive semantics: `F(psi) in chain(t)` and we need the F-obligation to propagate to M0. The FMCS has `forward_G`: `G(alpha) in chain(t) -> alpha in chain(s)` for `s >= t`. We need `F(psi)` itself, not `G(F(psi))`.

**Key**: `F(F(psi)) -> F(psi)` by `FF_imp_F` (line 61). And `F(psi) in chain(t)` gives `F(F(psi)) in chain(t)` by `phi_in_mcs_imp_F_phi`. So `F(F(psi)) in chain(t)`.

Does `F(F(psi))` propagate forward? `F(F(psi)) = neg G(neg F(psi)) = neg G(G(neg psi))`. This is NOT a G-formula, so g_content doesn't carry it.

**Viable path**: From `F(psi) in chain(t)` with `t < 0`, use BX4: `F(psi) -> G(P(F(psi)))`. So `G(P(F(psi))) in chain(t)`. By g_content: `P(F(psi)) in chain(0)`. By H-backward from chain(0): this gives `F(psi) in chain(s)` for some `s <= 0`. Actually, `P(F(psi)) in chain(0)` means `H(neg F(psi)) not_in chain(0)`, i.e., there exists some past time with `F(psi)`. But `P(F(psi))` at chain(0) means `exists s <= 0, F(psi) at chain(s)`, which we already know (it's at time t).

This is circular. The backward region F-propagation needs a different approach.

**The most viable path for sorry 2**: Prove that `F(psi) in chain(t)` for `t < 0` implies `F(psi) in chain(0)` by showing the backward chain construction preserves F-formulas upward (from more negative indices toward 0). The backward chain uses `bwd_pred` at each step. If the backward chain preserves f_carry-like properties (F-formulas propagating from `chain(t)` to `chain(t+1)` for `t < 0`), then `F(psi)` propagates to `chain(0)` and then sorry 1 handles the rest.

**BUT**: `bwd_pred` (CanonicalModel.lean:145) uses `h_content` and `p_carry`, NOT `g_content` and `f_carry`. The backward chain propagates H-content forward (toward less negative indices) and P-formulas. F-formulas are NOT preserved by the backward chain construction.

**This means sorry 2 may require modifying the backward chain construction** to also preserve F-formulas, or finding an alternative F-propagation path.

## Recommended Approach

### Primary Recommendation: Replace Chain Construction Entirely

**Confidence Level: 70%**

After exhaustive analysis, the most viable approach is the one consistently recommended across rounds 30-31: **replace the `rr_fwd_chain`/`rr_bwd_chain` construction with a chain where forward_F and backward_P are definitional, not post-hoc theorems.**

The specific construction should:

1. **At each forward step**, when `F(psi) in chain(n)` with `psi not_in chain(n)`:
   - Use `fwd_succ chain(n) h_n psi` in resolving mode
   - This gives `psi in chain(n+1)` (by `fwd_succ_resolves`, CanonicalModel.lean:92)
   - AND `g_content(chain(n)) subset chain(n+1)` (by `fwd_succ_g_content`, line 82)
   - forward_F at time n is witnessed by `s = n+1`

2. **When `F(psi) in chain(n)` and `psi in chain(n)`** (Case A from report 31):
   - `psi in chain(n)` but we need strict `s > n`
   - At step n+1, target some formula with a genuine defect (F(chi) present, chi absent)
   - If no genuine defects exist, all F-formulas have their targets present; use non-resolving step
   - In the non-resolving case: f_carry preserves F(psi), making psi a genuine defect at n+1; resolve at n+2

3. **For each formula phi with F(phi) in chain(n)**: forward_F is satisfied within at most 2 steps if phi is the next target, or within `|sigma_list| + 2` steps via round-robin.

**The catch (and why this is only 70% confidence)**: At resolving steps for OTHER formulas chi, the seed `{chi} union g_content(chain(n))` drops f_carry, potentially destroying `F(psi)`. Once `F(psi)` is lost (`G(neg psi)` enters), psi can never appear again. This is the same obstacle as before.

**The escape from the catch**: The defect-driven chain targets genuine defects first, not round-robin. When there IS a genuine defect (F(psi) present, psi absent), psi is targeted IMMEDIATELY at the next step. `F(psi)` only needs to survive ONE step (from n to n+1), and at step n+1 we use `fwd_succ` with target psi, which resolves it.

**The remaining gap**: Between the time `F(psi)` appears (time n) and the time psi is targeted (time n+1), another formula chi might be targeted instead (if chi has a smaller index in the defect list). The seed for chi's resolution is `{chi} union g_content(chain(n))`, which might kill `F(psi)`. But if we make psi the FIRST defect targeted (or the ONLY defect targeted), this gap vanishes.

**The construction that closes sorry 1**:

```
defect_fwd_chain(M0, sigma, n):
  n = 0: M0
  n + 1:
    let M = defect_fwd_chain(M0, sigma, n)
    let defects = [chi in sigma | F(chi) in M AND chi not_in M]
    if defects is nonempty:
      fwd_succ(M, defects.head)  -- resolve FIRST defect immediately
    else:
      fwd_succ(M, rrSchedule sigma n)  -- standard non-resolving step
```

**forward_F proof**: Given `F(psi) in chain(n)`:
- If `psi in chain(n)`: psi is not a defect. All defects get resolved one per step. After at most `|sigma|` steps, defect set is empty. At that point, the non-resolving step preserves f_carry, so `F(psi) in chain(n + k + 1)` (where k = number of defects at time n). Since `psi might not be in chain(n + k + 1)` (psi was in chain(n) but might have been lost), `psi` becomes a defect at `n + k + 1` and is resolved at `n + k + 2`.

**Gap in this argument**: Between step n and step `n + k`, other defects are being resolved. Each resolution uses `fwd_succ(M, chi)` with seed `{chi} union g_content(M)`. F(psi) is NOT in this seed. So F(psi) may be lost at step n+1, and then psi can never appear again.

**This is the SAME obstacle**. The defect-driven chain does not escape it because F-formulas for non-target defects are not in the resolving seed.

### The True Fix: Enrich the Seed with ALL Current Defects

The seed must include all current F-defects, not just the target. This is what `enriched_fwd_step` already does via the BX11 fold. But the BX11 fold only gives disjunctive preservation.

**The actual solution**: Build the chain so that at each step, the target is the ONLY defect. This means resolving defects one at a time in a SEQUENCE, and between resolutions, there is exactly one defect.

But defects can multiply (new F-formulas appear from Lindenbaum extensions).

### True Recommendation: Quasimodel-Derived Chain

**Confidence Level: 75%**

Given the exhaustive analysis above confirming that no modification of the linear Lindenbaum-extension chain can escape BX11 hijacking for the depth-0 case, the quasimodel-derived chain (approach A from round 30) remains the most viable path.

The construction outline:
1. For each F-defect `F(psi) in M0` with `psi in deferralClosure(root)`:
   - Use `bx_forward_witness` (Frame.lean:164) to get MCS `v_psi` with `g_content(M0) subset v_psi` and `psi in v_psi`
   - INSERT `v_psi` into the chain at some position `s > 0`
2. For Until defects: use `bx_until_eventuality_resolution` (Frame.lean:623) similarly
3. Chain positions between inserted witnesses use `fwd_succ` non-resolving steps

**The key insight that makes this work**: Each `bx_forward_witness` call gives a FRESH MCS with the target formula resolved. These MCS extend `g_content(M0)` (not `g_content(chain(n-1))`). So we need a chain structure where `g_content` is transitive from M0 to each witness.

**Obstacle**: The witnesses from `bx_forward_witness` extend `g_content(M0)`, but the FMCS chain needs `g_content(chain(n)) subset chain(n+1)` at EVERY step, not just from M0. If we insert witnesses at arbitrary positions, the g_content chain between adjacent witnesses might break.

**Resolution**: Build the chain as:
```
M0 -> v_1 -> v_2 -> ... -> v_k -> fwd_succ(v_k, ...) -> ...
```
where each `v_i` extends `g_content(M0)` (hence `g_content(v_{i-1})` since `g_content(M0) subset g_content(v_{i-1})` ... wait, this needs `g_content(M0) subset v_{i-1}` and `g_content(v_{i-1}) subset v_i`, which requires `g_content(v_{i-1}) subset g_content(M0)` -- NOT guaranteed).

**This is dead end 25/30 revisited**: BXPoint witnesses are not guaranteed to chain together with g_content inclusion at each step.

## Evidence/Examples

### Evidence that BX11 hijacking is persistent (not just theoretical)

The BX11 axiom `F(A) AND F(B) -> F(A AND B) OR F(A AND F(B)) OR F(F(A) AND B)` gives three cases. Case 3 wraps A in F. In the `enriched_fwd_fold` (lines 229-249), case 3 at a particular fold step causes the accumulated compound beta to become `F(beta) AND chi`. When beta's extraction function is applied, all previously tracked formulas get F-wrapped (line 240: `Or.inr (h_F_extract ...)`). This is NOT a theoretical possibility -- it's a structural feature of the fold that fires whenever the MCS happens to contain `F(F(beta) AND chi)` rather than the other two cases.

### Evidence that the quasimodel approach addresses the right abstraction level

The quasimodel's `defect_count` (Construction.lean:75) counts Until-defects and proves they decrease at each step. The analogous F-defect count does NOT decrease in the linear chain because new F-defects can appear via Lindenbaum extension. The quasimodel handles this by working at the Hintikka point level where the formula universe is FINITE (bounded by `|Sigma|`), and defects are tracked exactly. The chain-level construction inherits this termination.

### Evidence that sorry 5 (backward Until) needs the step transfer

The `backward_until_from_step` theorem (`UntilSinceCoherence.lean:111`) provides the complete proof of backward Until coherence GIVEN the step transfer. The step transfer `(phi U psi) in fam.mcs(r+1) AND phi in fam.mcs(r) -> (phi U psi) in fam.mcs(r)` is the ONLY remaining obligation. Every attempt to derive this from the existing chain properties fails because:
- g_content propagation goes forward (chain(r) -> chain(r+1)), not backward
- `(phi U psi)` is not a G-formula, so backward propagation of `G(phi U psi)` doesn't help
- BX4' gives `H(F(phi U psi))` from `(phi U psi)`, but extracting `(phi U psi)` from `F(phi U psi)` at an earlier time requires forward_F (circular)

## Confidence Level

**Overall: 55% for closing all 6 sorries with the current architecture.**

The confidence is lower than prior rounds because this analysis confirms that:

1. Sorry 1 (forward_F depth-0) is genuinely blocked by BX11 hijacking on ANY Lindenbaum-extension chain -- this is not a proof technique gap but a structural limitation of the construction.

2. Sorry 5 (backward Until step transfer) is an independent blocker that requires chain-level backward propagation of Until formulas, which the current g_content/h_content chain structure does not support.

3. Sorry 6 (forward Until) reduces to sorry 1 via BX9/BX10 extraction, plus the quasimodel's Until defect-discharge.

4. Sorries 2 and 3 (t < 0 cases) require F/P-propagation through the backward chain, which the current `bwd_pred`/`p_carry` infrastructure does not provide for F-formulas.

**The quasimodel-derived chain remains the recommended path**, but its implementation faces the g_content chaining obstacle (dead end 25/30) that needs a concrete resolution before implementation can proceed.

### What Would Raise Confidence to 80%+

A concrete proof (even on paper) that:
1. `bx_forward_witness` witnesses can be chained with g_content inclusion at each step, OR
2. A modified chain construction where the seed at each step includes BOTH the target formula AND a mechanism to preserve all other F-formulas consistently (not just disjunctively), OR
3. A proof that the step transfer for backward Until coherence follows from BX axioms applied to the chain's g_content structure, without needing forward_F.
