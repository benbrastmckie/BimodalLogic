# Teammate B Findings: Alternative Approaches (Round 30)

## Assignment

Research two alternative approaches for closing 6 sorry sites in `RootScopedChain.lean`:
- **Approach B**: Non-linear chain (omega-squared interleaving)
- **Approach C**: Dependent chain construction (Classical.choice)

Also consider novel approaches discovered during research.

---

## Approach B: Non-Linear Chain (Omega-Squared Interleaving)

### Concept

Replace the Int-indexed chain with interleaved sub-chains where each F-defect gets a dedicated resolution sub-chain. At time omega*i + j, resolve defect i using a single `fwd_succ` step, ensuring no interference from BX11 hijacking.

### Key Findings

**1. FMCS type constraints are fatal for omega-squared.**

The `FMCS` structure (FMCSDef.lean:99) requires `D : Type*` with `[Preorder D]`. The broader infrastructure (`dd_countermodel` at RootScopedChain.lean:3762) requires `D` with `AddCommGroup D`, `LinearOrder D`, and `IsOrderedAddMonoid D` for the `TaskFrame` and `TaskModel` construction.

Omega-squared (omega^2) is an ordinal, NOT a group. It has no additive inverse. The `AddCommGroup` constraint requires every element to have an inverse, which omega^2 does not satisfy. This is a **hard type-theoretic blocker** -- you cannot instantiate `FMCS (Ordinal)` or `FMCS (omega^2)` with the required algebraic structure.

**2. Cantor pairing encoding into Int does not help.**

One could try encoding omega^2 into Int via Cantor pairing: at time `pair(i,j)`, resolve defect i at step j. However, this does not solve the fundamental problem. The chain is still LINEAR (step k+1 is built from step k). Between the step dedicated to defect i and the step dedicated to defect i+1, the resolution of i+1's target may kill F-obligations for defect i. The interleaving structure is purely notational -- it does not change the fact that all defects share the chain state.

As RootScopedChain.lean:2112-2114 explicitly notes:
> "But this doesn't work either because the chain is a LINEAR sequence, and step k+1 is built from step k. The defects share the chain state."

**3. The interference problem is not about scheduling.**

The core obstruction is not that defects are scheduled in the wrong order. It is that `fwd_succ(M, target)` with `F(target) in M` uses seed `{target} union g_content(M)`, which does NOT include `f_carry(M)`. So resolving one F-defect can kill another F-obligation regardless of how steps are interleaved.

### Mathematical Soundness Assessment

**BLOCKED.** Omega-squared interleaving fails for two independent reasons:
1. The FMCS/BFMCS infrastructure requires `AddCommGroup D`, which omega^2 cannot satisfy
2. Even with Cantor pairing into Int, the linear chain state-sharing means defects still interfere

### Obstacles

| Obstacle | Severity | Details |
|----------|----------|---------|
| AddCommGroup on omega^2 | **Fatal** | Ordinals are not groups; no additive inverse |
| Linear state sharing | **Fatal** | Defects share chain state regardless of indexing scheme |
| Extended seed inconsistency | **Fatal** | `{target} union g_content(M) union f_carry(M)` can be inconsistent (proven in Sections 10-17 of the file) |

### Confidence Level

**95% confident this approach is blocked.** The algebraic constraint alone is fatal, and even without it, the linear state-sharing problem applies equally to any single-chain construction.

---

## Approach C: Dependent Chain Construction (Classical.choice)

### Concept

Define the chain by well-founded recursion where each step depends on the FORMULA being proved. For forward_F of psi, construct a chain that targets psi at the first step. Key idea: use `Classical.choice` to select good MCS at each time point.

### Key Findings

**1. bx_forward_witness gives per-formula witnesses, not chain-compatible witnesses.**

`bx_forward_witness` (Frame.lean:164-171) shows: given `F(psi) in w.formulas`, there exists `v : BXPoint` with `bx_le w v` (g_content preserved) and `psi in v.formulas`. The witness `v` is obtained via Lindenbaum extension of `{psi} union g_content(w.formulas)`.

Critically, `v` is a `BXPoint` (an arbitrary MCS), NOT `fam.mcs(s)` for any `s`. The forward_F requirement demands `psi in fam.mcs(s)` for some `s` in the FIXED chain `dd_chain`. A per-formula witness that lives outside the chain does not close the sorry.

**2. A single chain CANNOT be constructed per-formula.**

The `restricted_temporally_coherent` requirement (TemporalCoherence.lean:295-300) demands:
```
forall fam in B.families,
  forall t phi, phi in deferralClosure root ->
    F(phi) in fam.mcs t -> exists s > t, phi in fam.mcs s
```

The quantifier structure is: for ALL phi, there EXISTS s in the SAME family `fam`. The family is fixed before phi is chosen. So we cannot build a different chain for each phi -- the SAME `fam.mcs` function must work for all formulas simultaneously.

**3. Classical.choice applied naively creates a circular dependency.**

If we try to define `mcs(t) := Classical.choice (exists_good_mcs t)`, we need the existence proof `exists_good_mcs t` to establish that there is an MCS at time t satisfying all the coherence conditions. But the coherence conditions reference `mcs` at OTHER times (forward_G requires `mcs(t')` for `t' > t`), creating a circular dependency. Well-founded recursion on Int does not help because Int is not well-founded in both directions.

**4. The per-family approach doesn't resolve the core obstruction.**

Even if we could construct the chain differently, the mathematical content is the same: we need a single linear sequence of MCS where every F-obligation is eventually resolved. As the exhaustive analysis in Sections 1-18 of RootScopedChain.lean shows, the problem is that `{target} union g_content(M) union f_carry(M)` can be INCONSISTENT (explicit counterexample: target = G(neg chi) with F(chi) in M, giving {G(neg chi), F(chi)} = {G(neg chi), neg G(neg chi)} which derives bottom). This means no step function can simultaneously resolve a target AND preserve all other F-obligations.

**5. The G(F(psi)) case analysis is the correct decomposition.**

The analysis in Sections 18+ of RootScopedChain.lean reveals:
- If `G(F(psi)) in chain(n)`: F(psi) persists via g_content forever, and fwd_succ resolves psi at its visit step. **This case works.**
- If `G(F(psi)) not in chain(n)` (i.e., `F(G(neg psi)) in chain(n)`): F(psi) can be killed by other resolving steps. BX11 gives `F(psi and F(G(neg psi))) in chain(n)`, which implies psi appears at some future time... BUT the formula `psi and F(G(neg psi))` may not be in `sigma_list`, preventing recursive application.

### Mathematical Soundness Assessment

**BLOCKED.** The dependent chain construction fails because:
1. The FMCS requires a single chain for ALL formulas (universal quantification over phi)
2. Per-formula witnesses from `bx_forward_witness` live outside the chain
3. Classical.choice creates circular dependencies for bi-directional chains

### Obstacles

| Obstacle | Severity | Details |
|----------|----------|---------|
| Same-family requirement | **Fatal** | All formulas must use the same `fam.mcs` function |
| Witness outside chain | **Fatal** | `bx_forward_witness` gives BXPoint, not chain state |
| Circular definition | **Severe** | Well-founded recursion on Int is impossible (not well-ordered in both directions) |
| Extended seed inconsistency | **Fatal** | Same obstruction as Approach B |

### Confidence Level

**90% confident this approach is blocked** in its naive form. The same-family requirement and extended seed inconsistency are the fundamental obstructions.

---

## Novel Approaches Discovered

### Novel Approach 1: Weaken restricted_temporally_coherent

**Idea**: Change the `restricted_temporally_coherent` definition to allow per-formula families instead of requiring the same family for all formulas.

**Assessment**: This would require modifying the Truth Lemma, which uses `restricted_temporally_coherent` to prove the F-case. The Truth Lemma's F-case (evaluating `F(phi)` at time t in family fam) needs a witness s > t with phi at s IN THE SAME FAMILY fam (because the truth evaluation is parameterized by family). Weakening the coherence condition would break the Truth Lemma's F-case proof. **NOT viable without major refactoring of the algebraic representation theorem.**

### Novel Approach 2: One-family-per-F-obligation BFMCS

**Idea**: Instead of one family that handles all F-obligations, create a BFMCS where each family handles only ONE F-obligation. The bundle would have one family per (MCS, F-obligation) pair.

**Assessment**: This conflicts with how the Truth Lemma evaluates formulas. The truth evaluation is performed in a SINGLE family (the eval_family). All F-obligations encountered during recursive evaluation must be resolved within this one family. Having separate families per obligation doesn't help because the evaluation stays in one family. **BLOCKED by Truth Lemma architecture.**

### Novel Approach 3: The BX11 Closure + G(F(psi)) Case Split

**Most promising direction from the analysis.** The file's Section 18+ analysis reveals:

For depth-0 psi with F(psi) in chain(n):
- **Case G(F(psi)) in chain(n)**: F(psi) in g_content, persists forever via g_content propagation. Resolved at visit step. **DONE.**
- **Case F(G(neg psi)) in chain(n)**: By BX11 applied to F(psi) and F(G(neg psi)), eliminating impossible disjuncts, we get `F(psi and F(G(neg psi))) in chain(n)`. If we can show `psi and F(G(neg psi)) in chain(s)` for some s > n, then `psi in chain(s)` by conjunction elimination. This requires `psi and F(G(neg psi))` to be in `sigma_list` (deferralClosure).

**The approach**: Extend `deferralClosure` to include BX11-produced compound formulas. This is the "deferral disjunction" approach that `deferralDisjunctionSet` already partially implements. If the closure is sufficient (contains all formulas BX11 can produce during case analysis), the depth-0 case reduces to: either G(F(psi)) gives persistence, or BX11 produces a compound that can be resolved recursively.

**Key question**: Does the BX11 case analysis terminate? Each application of BX11 may produce new F-obligations. But f_nesting_depth of the compound `psi and F(G(neg psi))` is 0 (the conjunction is not an F-formula), so the same depth-0 argument applies recursively. The chain of BX11 applications is bounded by the finite deferralClosure. **This needs careful analysis to confirm termination.**

**Confidence**: 40% -- this is the most mathematically promising direction but requires significant work to verify that the deferralClosure is sufficient and that the BX11 case analysis terminates.

---

## Summary Table

| Approach | Viable? | Core Blocker | Confidence |
|----------|---------|--------------|------------|
| B: Omega-squared interleaving | **No** | AddCommGroup constraint + linear state sharing | 95% blocked |
| C: Dependent chain (Classical.choice) | **No** | Same-family requirement + extended seed inconsistency | 90% blocked |
| Novel 1: Weaken restricted_tc | **No** | Breaks Truth Lemma F-case | 95% blocked |
| Novel 2: Per-obligation families | **No** | Truth Lemma evaluates in single family | 95% blocked |
| Novel 3: BX11 closure + G(F(psi)) split | **Maybe** | Needs deferralClosure sufficiency + termination | 40% viable |

## Recommendation

Both assigned approaches (B and C) are blocked by fundamental architectural constraints. The most promising path forward from this analysis is **Novel Approach 3** (BX11 closure + G(F(psi)) case split), which aligns with the direction already explored in Sections 18+ of the RootScopedChain.lean analysis. This approach avoids the extended seed inconsistency by not trying to preserve f_carry, instead using BX11's own structure to decompose F-obligations into resolvable components.

The critical next step would be to verify that `deferralClosure` (or `extendedDeferralClosure`) contains all formulas that BX11 case analysis can produce, and that the recursive decomposition terminates.
