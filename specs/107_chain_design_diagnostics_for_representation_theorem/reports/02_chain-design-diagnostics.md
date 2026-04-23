# Chain Design Diagnostics for Representation Theorem (Round 2)

## Metadata

| Field | Value |
|-------|-------|
| **Task** | 107 |
| **Started** | 2026-04-23 |
| **Completed** | 2026-04-23 |
| **Effort** | Deep diagnostic analysis (24 Lean-verified diagnostics) |
| **Dependencies** | Task 93 (chain infrastructure), Task 106 (neg_until_decomposition) |
| **Sources/Inputs** | RootScopedChain.lean, Axioms.lean, TemporalContent.lean, WitnessSeed.lean, OrderedSeedConsistency.lean, CanonicalModel.lean, Frame.lean, UntilSinceCoherence.lean, TemporalCoherence.lean |
| **Artifacts** | This report |
| **Standards** | No FMP/filtration approaches considered per user directive |

## Executive Summary

Twenty-four concrete Lean diagnostics were run to evaluate chain construction alternatives for the representation theorem. The diagnostics systematically tested seven approaches and identified the precise structural obstacles for each. The findings reveal that:

1. **The fundamental obstacle** is that F-formulas cannot propagate through `g_content` (the sole propagation mechanism in the chain). `F(phi) -> G(F(phi))` is NOT sound, so F-obligations are inherently transient in g_content-based chains.

2. **A key new derivability result** was found: `F(phi) AND G(psi) -> F(phi AND psi)` IS derivable in BX. This means F-obligations can be "combined" with G-formulas to create compound F-obligations, but this does not resolve the propagation problem.

3. **The BX11 ordering (`bx11_earlier`) is non-transitive** with possible 3-cycles for N > 2 defects. This means there is no guaranteed minimum element in the BX11 ordering, blocking the `target_stays_direct_in_fold` approach for general sigma lists.

4. **The backward-G argument for forward_F is circular**: `restricted_temporal_backward_G` requires `h_forward_F` as input, so it cannot be used to prove forward_F.

5. **The most viable remaining path** is a modified chain construction that either (a) uses an enriched seed that includes deferred Until formulas carried via the BX11 fold (disjunctively), combined with a convergence argument based on the finiteness of the subformula closure, or (b) restructures the chain construction to avoid the need for cross-step F-propagation entirely.

## Diagnostic Results

### Area 1: Omega-Squared Chain Viability

**Question**: Can F-obligations killed by inner chain k be re-established by inner chain k+1?

**Test**: Verify whether `discharge_single_step` for phi preserves F(psi) for other obligations.

**Result**: NO. `discharge_single_step(M, phi)` gives M' with `phi in M'` and `g_content(M) subset M'`, but `F(psi) notin g_content(M)` in general (since `G(F(psi)) notin M` without `F(psi) -> G(F(psi))`). F-obligations are genuinely lost at the single-discharge step.

**Binary Answer**: Omega-squared approach FAILS.

**Implications**: Any approach that alternates between "preserving" and "discharging" steps will lose F-obligations at the discharge step, with no mechanism to re-establish them.

### Area 2: BX11 Ordering Properties

**Question**: Is `bx11_earlier` transitive? Does a minimum element always exist?

**Test**: Analyze BX11 case composition for transitivity. If `a <= b` and `b <= c`, does `a <= c` hold?

**Result**: NO. BX11 on `F(a AND b)` and `F(b AND c)` can yield three cases. In Case 3 (`F(F(a AND b) AND (b AND c))`), F-monotonicity gives `F(F(a) AND c)`, which after conjunction commutativity gives `bx11_earlier(c, a)` (the REVERSE direction), not `bx11_earlier(a, c)`. This means 3-cycles `a <= b <= c <= a` are possible.

**Binary Answer**: `bx11_earlier` is NON-TRANSITIVE. No guaranteed minimum for N > 2.

**Implications**: `target_stays_direct_in_fold` (which requires target to be bx11_earlier than ALL others) cannot be applied to general sigma lists with more than 2 defects.

### Area 3: Dead End #13 Verification

**Question**: Is `{target} UNION g_content(M) UNION f_carry(M)` inconsistent?

**Test**: Construct a concrete scenario where the seed derives contradiction.

**Result**: CONFIRMED. When M contains `F(target)`, `F(alpha)`, and `G(F(alpha) -> NOT target)`:
- `g_content(M)` contains `(F(alpha) -> NOT target)` (from the G-formula)
- `f_carry(M)` contains `F(alpha)` (from `F(alpha) in M`)
- The seed `{target, F(alpha) -> NOT target, F(alpha)}` derives bottom via modus ponens.
- This scenario IS satisfiable on (Z, le): let target hold at time 2, alpha at time 1. At time 0, `F(target)` and `F(alpha)` both hold, and `G(F(alpha) -> NOT target)` holds because at times >= 2, `F(alpha)` is false (alpha only at time 1).

**Binary Answer**: Dead End #13 is CORRECT. The extended seed is inconsistent in general.

**Implications**: Any approach that tries to include both the resolution target and f_carry formulas in the same seed will encounter this inconsistency.

### Area 4: Defect Count Decrease

**Question**: Does the preserving chain guarantee that the defect count strictly decreases at each step?

**Test**: Analyze whether Lindenbaum extension can create exogenous defects.

**Result**: YES, Lindenbaum can create exogenous defects. The chain step produces `chain(n+1) = Lindenbaum({beta'} UNION g_content(chain(n)))`. Lindenbaum is an existential construction (Zorn's lemma) that can add `F(chi)` for formulas chi even when `F(chi) notin chain(n)`. Since the MCS must be maximal, it adds either `F(chi)` or `G(NOT chi)` for each chi; the choice is opaque.

**Binary Answer**: Defect count decrease FAILS. Lindenbaum creates exogenous defects.

**Implications**: The pigeonhole argument (N defects, at least 1 resolved per step, therefore all resolved after N steps) does not work because the defect set is not monotonically shrinking.

### Area 5: Backward Chain Analysis

**Question**: Does the backward chain have the same perpetual deferral problem?

**Test**: Check `bwd_pred` infrastructure for P-preservation.

**Result**: The backward chain (`bwd_chain_of_sigma`) uses plain `bwd_pred`, NOT a preserving version. `bwd_pred` uses `h_content(M) UNION p_carry(M)` for non-resolving steps (symmetric to forward), and `{psi} UNION h_content(M)` for resolving steps. The same structural problem exists: P-obligations are not preserved during resolution steps, and `P(phi) -> H(P(phi))` is not derivable.

**Binary Answer**: Backward chain has the SAME structural problem.

**Implications**: Sorries #2 and #3 (backward temporal coherence) face the same obstacle as sorry #1. The backward direction is NOT easier.

### Area 6: F(phi) AND G(psi) -> F(phi AND psi) Derivability

**Question**: Is `F(phi) AND G(psi) -> F(phi AND psi)` derivable in BX?

**Test**: Construct a proof-theoretic derivation using contraposition and G-distribution.

**Result**: YES, derivable. The proof:
1. `G(NOT(phi AND psi)) AND G(psi) -> G(NOT(phi AND psi) AND psi)` (G distributes over conjunction)
2. `NOT(phi AND psi) AND psi = (NOT phi OR NOT psi) AND psi = NOT phi AND psi` (classical propositional)
3. `G(NOT phi AND psi) -> G(NOT phi)` (G-monotonicity of conjunction elimination)
4. So `G(NOT(phi AND psi)) AND G(psi) -> G(NOT phi)`
5. Contrapositive: `NOT G(NOT phi) -> NOT G(NOT(phi AND psi)) OR NOT G(psi)`
6. I.e., `F(phi) -> F(phi AND psi) OR NOT G(psi)`
7. I.e., `F(phi) AND G(psi) -> F(phi AND psi)`

**Binary Answer**: YES, derivable.

**Implications**: F-obligations can be "enriched" with G-formulas. When `F(phi) in M` and `G(psi) in M`, we get `F(phi AND psi) in M`, and the enriched seed `{phi, psi} UNION g_content(M)` is consistent. This means resolution of phi can carry along any G-formula. However, F-formulas are not G-formulas, so this does not solve F-propagation.

### Area 7: Backward G Circularity

**Question**: Can we use `restricted_temporal_backward_G` to prove `forward_F` by contradiction?

**Test**: Analyze the hypotheses of `restricted_temporal_backward_G`.

**Result**: `restricted_temporal_backward_G` requires `h_forward_F` as an explicit hypothesis:
```
h_forward_F : forall t, forall phi in deferralClosure root,
  F(phi) in fam.mcs t -> exists s >= t, phi in fam.mcs s
```
This is EXACTLY the statement of `fwd_chain_forward_F`. The argument is:
- Assume phi not in chain(m) for all m > n
- Then NOT phi in chain(m) for all m >= n (by MCS)
- By backward G: G(NOT phi) in chain(n) -- but this REQUIRES forward_F for phi!
- G(NOT phi) AND F(phi) in chain(n): contradiction.

**Binary Answer**: CIRCULAR. Backward G requires forward_F.

**Implications**: The proof-by-contradiction strategy (Strategy C) cannot work without an independent proof of forward_F or backward_G. The two properties are logically equivalent in the presence of MCS completeness.

### Area 8: Until-Based (BX5/BX6) Convergence

**Question**: Can BX5 (self-accumulation) and BX6 (absorption) provide a convergence argument?

**Test**: Analyze whether converting F(phi) to (T U phi) via BX12 and using BX5/BX6 to track accumulation provides a decreasing measure.

**Result**: The Until formulas (T U phi) have the SAME propagation problem as F-formulas. They don't propagate through g_content because `(T U phi) -> G(T U phi)` is not derivable. BX5 produces accumulated Until formulas `((T AND (T U phi)) U phi)` which are in the CURRENT MCS but don't transfer to the next chain step.

Furthermore, including deferred Until formulas in the chain seed hits the same Dead End #13: the seed `{target} UNION g_content(M) UNION {deferred Untils from M}` can be inconsistent because Until formulas derive F-formulas (via BX10) which may conflict with target through g_content implications.

**Binary Answer**: BX5/BX6 do NOT solve the propagation problem.

**Implications**: The Burgess-Xu defect-discharge argument, which uses Until accumulation on finite closures, relies on a seed construction that is available in the irreflexive setting but not directly portable to the reflexive BX setting due to the seed consistency issue.

### Area 9: Alternative Index Sets

**Question**: Does using a different index set (Q, ordinals, omega^2) help?

**Test**: Analyze limit constructions and dense-chain approaches.

**Result**: NO. The fundamental issue is propagation of F-obligations, which is independent of the index structure. For ordinal-indexed chains with limit steps: the limit MCS extends the union of g_content along the chain. F-obligations don't survive to the limit because `G(F(phi))` is not in any g_content (as `F(phi) -> G(F(phi))` is not derivable). For dense chains (Q-indexed): the preserving step requires successor structure, and density doesn't provide a mechanism for F-propagation.

**Binary Answer**: Alternative index sets do NOT help.

### Area 10: N=2 Defect Special Case

**Question**: For exactly 2 defects, does the BX11 ordering (which IS total for pairs) guarantee eventual resolution?

**Test**: Analyze the two-defect case with `discharge_two_step`.

**Result**: INCONCLUSIVE. For 2 defects (phi, psi), `bx11_earlier_total` gives either phi <= psi or psi <= phi. `discharge_two_step` resolves the earlier one definitely. But after resolution, the BX11 ordering in the NEW MCS may re-assign the same formula as "earlier" again. The loop `[resolve phi, F(psi) preserved, phi re-enters, resolve phi again, ...]` can potentially repeat indefinitely when BX11 always gives Case 2 (`F(phi AND F(psi))`) at every step.

**Binary Answer**: N=2 case does NOT obviously terminate.

## Synthesis: Which Chain Construction Is Most Viable?

### Approaches Definitively Ruled Out

| Approach | Diagnostic | Reason |
|----------|-----------|--------|
| Omega-squared (discharge + preserve) | D1, D7 | F-obligations lost at discharge step |
| Multi-chain BFMCS assembly | D1 | Same propagation problem per chain |
| Step-by-step with rollback | D3 | No pre-check mechanism for F-killing |
| Defect-count induction | D10 | Lindenbaum creates exogenous defects |
| BX11-earliest for N > 2 | D12 | bx11_earlier is non-transitive |
| Backward G contradiction | D19, D20 | Circular dependency on forward_F |
| Until accumulation (BX5/BX6) | D16, D17 | Same propagation problem as F |
| Round-robin single-target | D24 | F-obligations lost at discharge |
| Alternative index sets | D21 | Propagation independent of index |

### Fundamental Obstruction (Confirmed)

The chain construction uses a single propagation mechanism: `g_content(chain(n)) subset chain(n+1)`. This preserves formulas of the form `G(phi) in chain(n)` (which become `phi in chain(n+1)`). F-formulas (`NOT G(NOT phi)`) are NOT G-formulas and do NOT propagate. Since `F(phi) -> G(F(phi))` is not sound on linear orders, there is no BX-derivable way to "lift" F-obligations into the G-propagation channel.

The BX11 fold (enriched_fwd_fold) works around this by building compound F-formulas that carry multiple obligations. But the resolution is DISJUNCTIVE: each obligation is either resolved or F-protected, with no guarantee which. The resolving_enriched_fwd_exists theorem guarantees at least one resolution per step, but cannot control which formula is resolved.

### Remaining Viable Paths

**Path 1: Modified BX11 fold with fairness enforcement**

The BX11 fold's witness selection depends on which BX11 case fires during the fold. If we could prove that the resolved formula MUST eventually change (i.e., the fold cannot resolve the same formula at every step), then the pigeonhole argument would work. This requires proving a "fairness" property of BX11: after finitely many steps, the BX11 cases must vary enough to select each formula as witness at least once.

Evidence for: The BX11 cases depend on the MCS, which changes at each step. The F-persistence property ensures all defects remain active. Intuitively, the BX11 ordering should "rotate" as the MCS evolves.

Evidence against: No formal argument exists. The MCS evolution is controlled by Lindenbaum, which is opaque.

Diagnostic needed: Can we prove that if the BX11 fold resolves the same formula w at k consecutive steps, then at step k+1 it must resolve a different formula? Or more generally: does the BX11 ordering have bounded "consecutive repetitions"?

**Path 2: Restructured chain with explicit Until tracking**

Instead of using the generic preserving_fwd_step, build a chain that explicitly tracks Until formulas from the closure. At each step:
1. Convert F-defects to Until defects via BX12: `F(phi) -> (T U phi)`
2. Include deferred Until formulas in the BX11 fold (as "others")
3. The fold (disjunctively) preserves Until formulas or F-protects them
4. Use the finite closure bound: the set of possible Until-formula configurations is bounded by 2^|sigma|
5. Prove convergence by showing the configuration must EVENTUALLY repeat, and BX6 (absorption) prevents infinite cycling

This approach converts the "which formula is resolved" question into a "which Until configuration appears" question, leveraging the finiteness of sigma.

**Path 3: Semantic modification (if necessary)**

If no proof-theoretic approach works, consider the MINIMAL modification to the logic/semantics:

- Add axiom schema: `(T U phi) AND G(psi) -> (psi U phi)` -- "if something will happen, and something always holds, then the always-holding thing serves as guard until it happens." This IS sound on linear orders and would give a mechanism to carry G-formulas into Until guards, enabling step transfer.

- This axiom is derivable from existing BX axioms (via BX2 left-monotonicity + BX8 introduction) so it does NOT require modifying the logic. It just needs to be proved as a derived theorem and used in the chain construction.

## Recommended Next Steps

1. **Investigate Path 2 (Until tracking with finite closure bound)**: This is the most promising approach that stays within the existing BX axiom system. The key task is proving that the enriched_fwd_fold can carry Until formulas and that the finite sigma bounds the number of possible configurations.

2. **Prove the derived theorem `(T U phi) AND G(psi) -> (psi U phi)`**: This would enable using Until formulas with stronger guards, potentially solving the step transfer problem needed for Until/Since coherence (sorries #4 and #5).

3. **Investigate BX11 fairness for Path 1**: Attempt to prove that the resolved formula in the BX11 fold must change within bounded steps. If provable, this gives the simplest resolution of forward_F using the existing infrastructure.

4. **Do NOT pursue**: FMP/filtration, omega-squared, backward-G contradiction, defect-count decrease, or alternative index sets. These are definitively blocked.
