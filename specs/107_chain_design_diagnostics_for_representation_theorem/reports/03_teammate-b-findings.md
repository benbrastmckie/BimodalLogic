# Teammate B Findings: Alternative Approaches for Representation Theorem

**Task**: 107 - Chain Design Diagnostics for Representation Theorem
**Focus**: Alternative patterns, prior art, non-obvious approaches
**Date**: 2026-04-23

---

## Key Findings

### Finding 1: The FMP Infrastructure Gap -- "MCS-truth" is NOT Semantic Truth

**Confidence**: HIGH

The sorry-free FMP infrastructure (`Decidability/FMP/`) proves a purely proof-theoretic FMP: "if phi is not provable, there exists a closure MCS (finite model world) where phi is not a member." This is `mcs_finite_model_property` in `FMP.lean`. However, this does NOT constitute a completeness proof because:

1. **No semantic truth connection**: The FMP files define `filteredMcsTruth` (membership in closure MCS) and `mcsTruth`, but the `TruthPreservation.lean` file header explicitly says "Phase 4 infrastructure is in place. The full filtration lemma proof for all formula cases... requires additional work on modal/temporal MCS properties." The full filtration lemma connecting MCS-membership to truth in a TaskModel is NOT proven.

2. **No filtered TaskModel construction**: The `RefinedFilteredTaskFrame` is defined in `Filtration.lean` but there is no `TaskModel` over it with a valuation, and no truth lemma connecting `filteredWorldMem` to `truth_at` on a TaskModel. The missing piece is the SAME as the missing piece in the chain approach: temporal coherence for F/P obligations on the filtered model.

3. **The temporal truth preservation problem recurs**: Even in a filtered model, proving `G(phi) in S iff forall successor worlds S', phi in S'` requires the same structural properties (forward_F, backward_P) that are missing in the chain. The filtration approach merely shifts where the sorry appears -- from chain construction to filtered truth preservation.

**Implication**: The FMP infrastructure CANNOT be composed to bypass the chain construction. The same fundamental obstacle (F-propagation through temporal operators) would reappear in the filtration truth lemma. The existing sorry-free FMP results are proof-theoretic bookkeeping, not a semantic completeness proof.

### Finding 2: The ParametricRepresentation + RestrictedParametricTruthLemma Architecture is Sound and Nearly Complete

**Confidence**: HIGH

The architecture in `Algebraic/ParametricRepresentation.lean` and `Algebraic/RestrictedParametricTruthLemma.lean` is already correct and sorry-free. The completeness proof in `BXCanonical/Completeness.lean` correctly calls `dd_countermodel` which uses `fully_restricted_parametric_representation_from_neg_membership`. The ONLY gap is providing implementations of three predicates:

1. `dd_bfmcs_restricted_tc` (sorry at line 1143 + 1170 + 1177): restricted temporal coherence
2. `dd_bfmcs_restricted_buc` (sorry at line 1185): restricted backward until/since coherence
3. `dd_bfmcs_restricted_fuc` (sorry at line 1192): restricted forward until/since coherence

Everything above this layer is proven. The question is SOLELY how to construct a BFMCS satisfying these three properties.

### Finding 3: Quotient Chain via Finite Closure Repetition

**Confidence**: MEDIUM

The subformula closure `subformulaClosure phi` is finite (this is proven in the codebase). The chain `dd_chain M_0 h_0 sigma_list n` produces a sequence of MCS. While each MCS is an infinite set, its *restriction to the subformula closure* is one of finitely many possibilities (bounded by `2^|subformulaClosure phi|`). By pigeonhole, the restricted chain must REPEAT within `2^|closure|` steps.

The question is whether this repetition can be exploited:

**What repetition gives you**: If `chain(k)` and `chain(k+p)` agree on all closure formulas (including `F(chi)` for `chi` in the closure), then:
- `F(chi) in chain(k)` iff `F(chi) in chain(k+p)` -- the same F-defects appear
- `G(psi) in chain(k)` iff `G(psi) in chain(k+p)` -- the same G-formulas persist
- The chain from `k` to `k+p` forms a "period" where the closure-restricted content repeats

**What repetition does NOT directly give you**: The chain between `k` and `k+p` might resolve some defects and introduce others, with the net effect being zero. But if `F(chi) in chain(k)` (period start) and `F(chi) in chain(k+p)` (period end), then somewhere in `[k, k+p]` the chain either resolved `chi` or didn't. If it didn't resolve chi in one full period, it won't in any subsequent period either (same closure-restricted content, same Lindenbaum choices).

**Critical gap**: Lindenbaum's lemma uses Zorn's lemma (or enumeration) and its choices may differ on the same input. Two MCS with the same closure-restricted content are NOT necessarily identical as full MCS. So the chain may not literally repeat -- only its closure-restriction repeats. This means the argument needs to work with closure-restricted equality, not full MCS equality.

**Verdict**: The quotient approach is theoretically interesting but requires proving that the BX11 fold's behavior depends only on closure-restricted content, which is plausible but non-trivial.

### Finding 4: Literature Pattern -- Burgess/Reynolds "Finite Unravelling" for Until

**Confidence**: MEDIUM-HIGH

The standard completeness proof for temporal logic with Until (Burgess 1984, Reynolds 2003) uses a technique distinct from the current chain construction:

**Burgess's approach**: Rather than building an omega-chain and proving F-propagation globally, Burgess builds a FINITE chain segment for each Until obligation separately. The key steps are:

1. Start with MCS `w` containing `F(phi)` (or `phi U psi`)
2. Use BX11 (linearity) to establish that witnesses are linearly ordered
3. Build a FINITE defect-discharge chain of length at most `|Sigma|` (the closure size)
4. The termination argument is: at each step, at least one defect is discharged AND no new defects IN THE CLOSURE are created (because the closure is closed under subformulas)

**Why this differs from the current approach**: The current chain tries to build ONE infinite chain that satisfies ALL coherence properties simultaneously. Burgess instead builds SEPARATE finite witness chains for each temporal obligation, then PASTES them together.

**The Burgess "pasting" step**: Given the starting MCS `w` and a finite witness chain `w = v_0, v_1, ..., v_k` where `phi in v_k`, the construction uses:
- `bx_le(v_i, v_{i+1})` between consecutive points (g_content inclusion)
- The finiteness of the chain guarantees termination
- Multiple chains for different obligations are merged by taking appropriate BFMCS families

**Connection to existing code**: The `Quasimodel/Construction.lean` file implements exactly this pattern but is marked "OFF-PATH." The `hintikka_step` definition and `defect_count` infrastructure are correct. The problem was connecting quasimodel chains (which are BXPoint-level) to the FMCS chain (which is MCS-level). The `QuasimodelBridge.lean` (also marked "OFF-PATH") was the attempted bridge.

**Why it was abandoned**: The guard condition `forall u with bx_le w u and bx_le u v_k and not(bx_le v_k u), phi in u` requires controlling ALL intermediate points, which is impossible when `bx_le` is a preorder (not total). But under the restricted approach (restricting to `subformulaClosure(root)`), the guard only needs to hold for closure formulas, which is a weaker requirement.

**Recommendation**: Revisit the quasimodel approach with the RESTRICTED coherence definitions. The current sorry targets only require restricted temporal coherence (`dd_bfmcs_restricted_tc`), which quantifies over `deferralClosure(root)` only. A finite quasimodel chain that resolves F-obligations within the closure should suffice.

### Finding 5: Compatible F-Enrichment -- A Selective f_carry

**Confidence**: MEDIUM

Dead End #13 shows that `{target} UNION g_content(M) UNION f_carry(M)` is inconsistent in general. But the counterexample requires a SPECIFIC structure: `G(F(alpha) -> NOT target) in M`. What if we only include F-formulas that are COMPATIBLE with the target?

Define: `compatible_f_carry(M, target) = {F(chi) in M : G(target -> NOT chi) NOT_IN M AND G(F(chi) -> NOT target) NOT_IN M}`

The seed `{target} UNION g_content(M) UNION compatible_f_carry(M, target)` avoids Dead End #13 because:
- If `G(F(chi) -> NOT target) in M`, then `F(chi)` is excluded from the seed
- If `G(target -> NOT chi) in M`, then... this is NOT directly excluded

**Problem**: The incompatibility `G(target -> G(NOT chi)) in M` (which gives `target -> NOT chi in g_content(M)`) is the true obstruction. Even without `F(chi)` in the seed, having `F(chi) -> NOT target` in `g_content(M)` means `F(chi) in seed` leads to `NOT target in M'`, contradiction. But the exclusion criterion above only checks `G(F(chi) -> NOT target)`, not the deeper structural incompatibility via g_content implications.

A correct exclusion criterion would need to check: "does `g_content(M) UNION {target, F(chi)}` derive contradiction?" This is undecidable in general for infinite MCS, though decidable when restricted to the finite closure.

**Refinement**: When restricted to the finite closure `Sigma`, we can enumerate all F-formulas `F(chi)` with `chi in Sigma` and check consistency of each enrichment against `g_content(M) ∩ Sigma`. Since the closure is finite, this is decidable. We include only the F-formulas whose inclusion is consistent.

**Problem with this refinement**: Classical logic gives consistency OR inconsistency, but the Lindenbaum construction uses non-constructive choice. We can't "try" including `F(chi)` and backtrack if it fails. We would need to prove that the MAXIMALLY compatible set of F-formulas is consistent with target, which requires a careful inductive argument.

**Verdict**: Interesting direction but technically challenging. The key question is whether a maximal compatible subset of f_carry can be proven consistent via BX11 fold or a similar mechanism.

### Finding 6: The "Backward-From-Endpoint" Pattern

**Confidence**: LOW

Instead of building forward from `M_0` trying to resolve F-obligations, consider building backward from a hypothetical "all-resolved" MCS:

1. Assume `F(phi) in M_0` for target phi
2. By `forward_temporal_witness_seed_consistent`: `{phi} UNION g_content(M_0)` is consistent
3. Extend to MCS `M_1` with `phi in M_1` and `g_content(M_0) subset M_1`
4. For each `F(chi)` in `M_0`, check if `F(chi)` survived to `M_1`:
   - If yes, `F(chi) in M_1`, we still need to resolve chi
   - If no, `G(NOT chi) in M_1`, which means chi was "killed"
5. Recursively resolve remaining F-obligations from `M_1`

**The key insight**: Each step DEFINITELY resolves the target (phi enters `M_1`). The question is which other F-obligations survive. Since we're tracking within the closure (finite set), the number of possible F-obligation sets is bounded by `2^|Sigma|`. If an F-obligation is killed, it stays killed (because `G(NOT chi) in M_1` propagates forward via g_content). So the number of surviving F-obligations is non-increasing.

**Critical question**: Is it STRICTLY decreasing? If `F(chi)` survives to `M_1` (i.e., `F(chi) in M_1`), can we show that at the NEXT step (resolving chi), the set of surviving obligations STRICTLY decreases?

**Answer**: NOT necessarily. The step resolving chi creates `M_2` with `chi in M_2`. But `M_2` is a Lindenbaum extension, so it may introduce NEW F-obligations `F(gamma)` that weren't in `M_1`. However, `gamma` must be in the closure for us to care (restricted coherence). The closure contains finitely many formulas. If the chain creates a new F-obligation `F(gamma)` for `gamma in Sigma`, then this is a "new defect." But Lindenbaum's exogenous defect creation means the count is NOT monotonically decreasing.

**Verdict**: Same fundamental problem as the forward chain. Lindenbaum's non-determinism prevents a clean termination argument.

### Finding 7: Reframing the Problem -- What the Sorry Targets Actually Need

**Confidence**: HIGH

Let me state precisely what needs to be proved, separated from how:

**Sorry 1 (`fwd_chain_forward_F`, line 1143)**: Given `F(phi) in chain(n)` with `phi in sigma_list`, prove `exists m > n, phi in chain(m)`.

**Sorry 2 (backward chain F-resolution, line 1170)**: Same as Sorry 1 but for the backward chain region (`t - s < 0`).

**Sorry 3 (backward P-resolution, line 1177)**: Given `P(phi) in chain(t)`, prove `exists u < t, phi in chain(u)`. Symmetric to Sorry 1 using the backward chain.

**Sorry 4 (`dd_bfmcs_restricted_buc`, line 1185)**: Restricted backward Until/Since coherence. Given semantic witness (ψ at some s >= t, φ on guard [t,s)), prove `(φ U ψ) in fam.mcs t`. This uses `backward_until_from_step` which requires a "step transfer" property.

**Sorry 5 (`dd_bfmcs_restricted_fuc`, line 1192)**: Restricted forward Until/Since coherence. Given `(φ U ψ) in fam.mcs t`, prove there exists a witness with the guard condition.

**Observation**: Sorries 4 and 5 are DIFFERENT in nature from Sorries 1-3. Sorries 1-3 are about F/P resolution (temporal coherence). Sorries 4-5 are about Until/Since coherence (semantic content of Until/Since operators matching MCS membership). The existing research focuses mostly on Sorries 1-3 (the F-propagation problem). Sorries 4-5 have received less attention but are potentially EASIER because:

- **Sorry 4** (backward Until) requires the step transfer property: `(phi U psi) in chain(n+1) AND phi in chain(n) -> (phi U psi) in chain(n)`. Under BX reflexive semantics, `or_until_in_mcs` gives `(psi OR (phi AND (phi U psi))) in M -> (phi U psi) in M`. So if we can show either `psi in chain(n)` or `(phi AND (phi U psi)) in chain(n)`, we're done. The second disjunct requires `phi in chain(n)` (given) AND `(phi U psi) in chain(n)` (what we're trying to prove -- circular). The first disjunct `psi in chain(n)` may fail. So the step transfer DOES require something beyond `or_until_in_mcs`.

- **Sorry 5** (forward Until) requires: `(phi U psi) in chain(n) -> exists m >= n, psi in chain(m) AND forall r in [n,m), phi in chain(r)`. BX10 gives `F(psi) in chain(n)`. If Sorry 1 is solved, we get `psi in chain(m)` for some m > n. But we also need the guard condition: `phi in chain(r)` for all r in [n,m). BX9 gives `phi in chain(n)` (or `psi in chain(n)`, in which case m = n and we're done). BX5 gives `(phi AND (phi U psi)) U psi in chain(n)`. But the guard between n and m requires showing `phi` persists at every intermediate chain step, which is exactly the Until propagation problem.

### Finding 8: The Derived Theorem `(T U phi) AND G(psi) -> (psi U phi)` Enables a New Approach

**Confidence**: MEDIUM-HIGH

Report 02 (Area 6) established that `F(phi) AND G(psi) -> F(phi AND psi)` is derivable. Building on this, consider the derived theorem:

`(T U phi) AND G(psi) -> (psi U phi)`

**Derivation sketch**:
1. BX2 (left monotonicity): `G(T -> psi) -> ((T U phi) -> (psi U phi))`
2. `G(T -> psi)` is equivalent to `G(psi)` (since `T -> psi` iff `psi`)
3. So `G(psi) -> ((T U phi) -> (psi U phi))`
4. Combining: `(T U phi) AND G(psi) -> (psi U phi)`

**Why this matters**: If `(phi U psi) in chain(n)`, BX5 gives `((phi AND (phi U psi)) U psi) in chain(n)`. Using BX12 on `F(psi)` gives `(T U psi) in chain(n)`. If we also have `G(phi) in chain(n)`, then the derived theorem gives `(phi U psi) in chain(n)` -- but we DON'T have `G(phi) in chain(n)` in general (phi may only hold at n, not at all future times).

However, for the GUARD condition: if `phi in chain(r)` for all r in [n, m), we need to show this propagates. If the chain has g_content inclusion, then `G(phi) in chain(n)` would give `phi in chain(r)` for r >= n. But we DON'T have `G(phi)`.

**What we DO have**: `phi in chain(n)` (from BX9) and `(phi U psi) in chain(n)`. At the next step `chain(n+1)`, we have `g_content(chain(n)) subset chain(n+1)`. From BX5: `((phi AND (phi U psi)) U psi) in chain(n)`. So `F(psi) in chain(n)` (BX10) and `F(phi AND (phi U psi)) in chain(n)` or `psi in chain(n)`.

The key difficulty remains: `(phi U psi)` is NOT a G-formula, so it doesn't propagate through g_content to chain(n+1). The derived theorem helps with guard conditions but doesn't solve the propagation problem.

---

## Prior Art Analysis

### Burgess 1984 ("Basic Tense Logic")

Burgess's completeness proof for Kt.BU (basic tense logic with Until) uses:
1. **Hintikka sets** (finite consistent subsets of a closure) rather than full MCS
2. **Finite chains** of Hintikka points, with defect discharge terminating by pigeonhole on the finite closure
3. **Pasting**: Multiple finite chains are pasted into an omega-chain

The critical difference from the current approach: Burgess works with FINITE sets (Hintikka points) throughout. The subformula closure is finite, so the Hintikka points form a finite set, and chains through them must repeat. The current approach works with INFINITE MCS and only restricts to the closure at the end.

**Applicability**: The existing `Quasimodel/HintikkaPoint.lean` implements Hintikka points. The existing `Quasimodel/Construction.lean` implements the defect discharge chain (marked OFF-PATH). If the restricted coherence framework (`restricted_temporally_coherent`) can be connected to finite Hintikka chain existence, this bypasses the infinite-chain F-propagation problem entirely.

### Reynolds 2003 ("An Axiomatization of Full Computation Tree Logic")

Reynolds's approach for Until-rich temporal logics uses:
1. **Rule-based canonical model**: Rather than building a chain point-by-point, Reynolds defines rules that constrain how successor states relate to predecessor states
2. **Maximal consistent rule-sets**: These encode the temporal obligations
3. **Tree unravelling**: The canonical model is a tree, and temporal operators are interpreted along branches

**Applicability**: The tree structure avoids the linearity requirement that makes BX11 fold problematic. In a tree, each branch can independently resolve its F-obligations. However, TM logic requires linear time (not branching), so the tree approach needs adaptation.

### Goldblatt 1992 ("Logics of Time and Computation")

Goldblatt's completeness proof for tense logics with linearity uses:
1. **Canonical frame construction**: Standard MCS-based
2. **Filtration**: For FMP, quotient by closure equivalence
3. **Key trick**: The linear frame is obtained by unravelling the canonical model along a maximal chain

**Key observation**: Goldblatt's approach for the COMPLETENESS (not FMP) constructs the canonical model as a full MCS frame and then uses the linearity axioms to prove frame properties. The temporal coherence (F-resolution) follows from the DENSITY of the canonical frame -- between any two related MCS, there exists an intermediate one. For discrete frames, the coherence follows from successor existence.

### Xu 1988 ("An Axiomatization of Common Knowledge")

Xu's work on bimodal completeness with S5 + temporal components uses:
1. **Generated submodels**: Restrict the canonical model to a generated submodel containing the falsifying point
2. **Temporal unravelling**: Build an omega-chain through the generated submodel
3. **Key innovation**: Use the S5 accessibility relation (equivalence classes) to control modal content, while building temporal chains within each equivalence class

**Applicability to TM**: The TM logic has Box as S5 (reflexive, transitive, symmetric -- but here specifically: modal_t, modal_4, modal_b). The temporal operators (G, H, F, P, U, S) are over a linear order. Xu's technique of separating modal from temporal reasoning matches the existing architecture:
- `BFMCS.modal_forward` / `BFMCS.modal_backward` handle modal saturation (sorry-free)
- The temporal chain handles temporal obligations (has sorries)

The separation is already implemented. The remaining question is purely about temporal chain construction within a single family.

---

## Recommended Approach

### Primary Recommendation: Finite Quasimodel Chain via Restricted Closure

**Confidence**: MEDIUM-HIGH

Rather than trying to prove F-propagation along an infinite chain, restructure the proof to use FINITE witness chains for each F-obligation within the restricted closure.

**Strategy**:

1. **For Sorry 1 (forward_F restricted)**: Given `F(phi) in chain(n)` with `phi in deferralClosure(root)`:
   - The chain at step n is an MCS containing `F(phi)`
   - BX12 gives `(T U phi) in chain(n)` from `F(phi)`
   - Build a SEPARATE finite chain of length at most `|Sigma|` resolving phi
   - Use the quasimodel defect discharge infrastructure (already implemented in `DefectChain.lean`)
   - The finite chain guarantees phi appears at some endpoint
   - Map this finite chain back to the dd_chain indices

   **Key difficulty**: The separate finite chain's MCS are not the same as dd_chain's MCS. They share g_content but may differ on other formulas. To use the separate chain, we would need to show that the phi-witness from the separate chain can be "embedded" into the dd_chain.

2. **For Sorry 4 (backward Until)**: Given semantic witness pattern, derive `(phi U psi) in chain(n)`:
   - For `n = m` (reflexive case): Use BX8 (`psi -> (phi U psi)`)
   - For `n < m`: Need step transfer. The step transfer for restricted coherence only requires it for Until formulas in `subformulaClosure(root)`, which is a finite set. Enumerate and prove each case via BX8 + `or_until_in_mcs`.

3. **For Sorry 5 (forward Until)**: Given `(phi U psi) in chain(n)` with `(phi U psi) in subformulaClosure(root)`:
   - BX10 gives `F(psi) in chain(n)` with `psi in subformulaClosure(root)`
   - `psi in deferralClosure(root)` (subformula closure subset of deferral closure)
   - By Sorry 1 (if solved): `psi in chain(m)` for some `m > n`
   - Guard condition: Show `phi in chain(r)` for `r in [n, m)`. This is the hard part. BX5 gives `((phi AND (phi U psi)) U psi) in chain(n)`, so at step n, `phi AND (phi U psi) in chain(n)` (from BX9, if `psi not in chain(n)`). But this doesn't give phi at steps r > n.

### Secondary Recommendation: Redefine the Chain Construction

**Confidence**: MEDIUM

Instead of the current `fwd_succ` / `preserving_fwd_step` approach, define a new chain construction that explicitly tracks and propagates Until formulas:

**Modified chain step**: For each step `chain(n) -> chain(n+1)`, define:
```
seed(n) = {scheduled_target(n)} UNION g_content(chain(n)) UNION until_carry(chain(n), Sigma)
```
where `until_carry(M, Sigma) = {(phi U psi) : (phi U psi) in M AND (phi U psi) in Sigma AND psi not in M}`

**Why Until-carry might be consistent**: Unlike `f_carry(M)` which includes `F(chi)` (problematic because `F(chi)` can conflict with targets via g_content implications), the Until formulas `(phi U psi)` are WEAKER than `F(psi)` + guard. More precisely, `(phi U psi)` is equivalent to `psi OR (phi AND F(phi U psi))` (by BX9 + BX5 + BX10), so it carries less information than `F(psi)` alone.

**However**: `(phi U psi)` implies `F(psi)` (BX10), so including `(phi U psi)` in the seed also includes `F(psi)` derivatively. If `G(target -> NOT psi) in M`, then `g_content(M)` includes `(target -> NOT psi)`, and the seed `{target, (phi U psi)} UNION g_content(M)` derives: `(phi U psi) -> F(psi)` (BX10), and then... we get `F(psi) in M'` but not necessarily `psi in M'` (F is existential). So the conflict via `(target -> NOT psi)` only fires if `psi in M'`, not if `F(psi) in M'`.

**Key question**: Is `{target} UNION g_content(M) UNION until_carry(M, Sigma)` consistent? The Dead End #13 counterexample used `F(alpha)` in the seed, not `(phi U alpha)`. The Until formula is weaker. But `(phi U alpha)` derives `F(alpha)` via BX10 in the extended MCS, so the same counterexample construction would apply.

**Verdict**: Until-carry has the same consistency problem as f_carry. This approach does NOT avoid Dead End #13.

---

## Evidence/Examples

### Example 1: Closure Repetition Bounds

For a formula phi with `|subformulaClosure(phi)| = k`, the chain restricted to the closure has at most `2^k` distinct states. So within `2^k + 1` steps, a repetition must occur. For practical formulas in the TM logic (e.g., `Box(p) -> G(F(p))`), k is small (~20), so the repetition bound is ~1 million steps.

### Example 2: The Existing Sorry-Free Infrastructure Inventory

| Module | Sorry-free? | What it proves |
|--------|-------------|---------------|
| `ParametricRepresentation.lean` | YES | Countermodel from neg-membership in BFMCS |
| `ParametricTruthLemma.lean` | YES | Truth lemma assuming full coherence |
| `RestrictedParametricTruthLemma.lean` | YES | Truth lemma assuming restricted coherence |
| `Decidability/FMP/` (all files) | YES | MCS-based FMP (proof-theoretic only) |
| `Bundle/TemporalCoherence.lean` | YES | Coherence definitions + backward G/H from forward_F/backward_P |
| `Bundle/UntilSinceCoherence.lean` | YES | Backward Until/Since from step transfer |
| `BXCanonical/OrderedSeedConsistency.lean` | YES | Enriched seed consistency |
| `BXCanonical/Frame.lean` | 4 sorries | BXPoint-level Until/Since resolution |
| `BXCanonical/RootScopedChain.lean` | 5 sorries | The chain construction |
| `BXCanonical/Completeness.lean` | YES (uses dd_countermodel) | bx_completeness wired through |

### Example 3: The Step Transfer Gap

The backward Until coherence (`backward_until_from_step` in `UntilSinceCoherence.lean`) requires a step transfer property parameterized as a hypothesis. Any chain construction providing this hypothesis gets backward Until for free. The step transfer is:

```
forall n phi psi, (phi U psi) in chain(n+1) -> phi in chain(n) -> (phi U psi) in chain(n)
```

Under BX reflexive semantics, this reduces to showing that either `psi in chain(n)` (use BX8) or `phi AND (phi U psi) in chain(n)` (need `(phi U psi) in chain(n)` -- circular unless we have Until propagation backward through the chain).

The step transfer would follow immediately if the chain had "backward Until content": `{(phi U psi) : (phi U psi) in chain(n+1)} subset chain(n)`. But the chain only has h_content backward propagation (`H(phi) in chain(n+1) -> phi in chain(n)`), and Until is not an H-formula.

---

## Summary of Confidence Levels

| Finding | Confidence | Impact |
|---------|------------|--------|
| FMP infrastructure cannot bypass chain | HIGH | Rules out the "just use FMP" approach |
| Architecture above chain layer is sound | HIGH | Confirms the problem is precisely scoped |
| Quotient chain via closure repetition | MEDIUM | Theoretically interesting, technically hard |
| Burgess finite unravelling pattern | MEDIUM-HIGH | Most promising alternative architecture |
| Compatible F-enrichment | MEDIUM | Avoids Dead End #13 partially but may not suffice |
| Backward-from-endpoint | LOW | Same termination problem |
| Sorry target decomposition | HIGH | Clarifies that sorries 4-5 differ from 1-3 |
| Derived `(T U phi) AND G(psi) -> (psi U phi)` | MEDIUM-HIGH | Useful tool but doesn't solve core problem |
