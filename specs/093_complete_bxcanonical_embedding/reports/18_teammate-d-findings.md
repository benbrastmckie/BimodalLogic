# Teammate D Findings: Task 93 Round 18 -- Horizons Research

**Date**: 2026-04-14
**Role**: Teammate D -- Horizons Researcher
**Focus**: Long-term architectural assessment, alternative completeness proof techniques, cost-benefit of restructuring

---

## Key Findings

### 1. The forward_F problem is NOT a fundamental architectural flaw

The proof architecture (MCS -> chain -> BFMCS -> parametric canonical model -> completeness) is mathematically correct and matches the standard Burgess-Xu completeness proof structure. The forward_F problem is a **construction-level** issue, not an architecture-level one. Specifically:

- The `fully_restricted_parametric_representation_from_neg_membership` theorem (RestrictedParametricTruthLemma.lean:471) requires three restricted coherence conditions: `restricted_temporally_coherent`, `restricted_backward_until_since_coherent`, and `restricted_forward_until_since_coherent`.
- The chain construction (`rr_fwd_chain` / `dd_chain`) provides g_content propagation, box stability, and F-preservation disjunction (`chi in M' OR F(chi) in M'`).
- The gap: the disjunction from BX11 fold prevents guaranteeing `psi in chain(s)` for a specific `s > n`.

The existing infrastructure (16 sorry-free lemmas, 2289+ lines of sorry-free code, parametric canonical model, truth lemma, Frame.lean eventuality resolution) is sound. Only the chain's forward step function needs to be strengthened.

### 2. The proof should NOT be restructured entirely

19 approaches have been tried and documented (Report 17). The infrastructure investment is substantial and correct. A complete restructuring would require re-proving 30+ theorems across 7 files. The correct strategy is to fix the chain construction at the leaf level, not to replace the architecture.

---

## Alternative Proof Architectures

### A. Step-by-Step Henkin-Style Construction

**Idea**: Instead of building the chain with `.choose` at each step (which picks an ARBITRARY Lindenbaum extension), build it with controlled choices informed by what needs to be resolved.

**Feasibility**: MEDIUM. The current chain already uses `enriched_fwd_step` which controls the seed. The problem is that BX11 fold returns a disjunction (`chi in M' OR F(chi) in M'`), not a conjunction. A Henkin-style approach would need to ensure `chi in M'` directly. This is exactly what `enriched_resolving_seed_consistent` from `OrderedSeedConsistency.lean` provides: if `F(A and B) in M`, then `{A, B} union g_content(M)` is consistent, guaranteeing both `A in M'` AND `B in M'` after Lindenbaum extension.

**Key obstacle**: To use `enriched_resolving_seed_consistent`, the chain step must produce `F(psi_j and compound)` in the current MCS (via BX11 case 1 or 2). This requires `psi_j` to be the "earliest witness" among all F-defects. The `find_earliest_witness` function (described in handoff 15) would need BX11 to be acyclic on F-defects, which the 3-cycle counterexample (Report 16) suggests may fail.

**Would preserve**: ALL existing infrastructure. Only `enriched_fwd_step` and `rr_fwd_chain_forward_F` change.

**Cost**: 5-10 hours if the earliest-witness approach works; INFEASIBLE if BX11 cycling prevents it.

### B. Filtration-Based Completeness

**Idea**: Use the existing filtration infrastructure (Decidability/FMP/Filtration.lean) to bypass chains entirely. Filtration constructs finite models from infinite ones by quotienting by subformula closure agreement.

**Feasibility**: LOW for completeness. The FMP filtration proves "satisfiable -> satisfiable in finite model" which is the wrong direction for completeness (we need "not provable -> not valid"). The FMP approach starts from a model, while completeness starts from syntax. The FMP proof also uses `ClosureMCSBundle` (a different infrastructure from `BFMCS`), so it would require building a new bridge.

**Would preserve**: Nothing from the current completeness path. Would require an entirely new proof.

**Cost**: 40+ hours. Would need to prove that the filtered model satisfies all BX axioms (the FMP filtration only preserves truth of specific formulas within the closure, not general axiom soundness). This is a known difficulty for temporal logic filtrations -- Until/Since semantics do not filter cleanly.

**Verdict**: NOT RECOMMENDED. The existing filtration is for decidability, not completeness, and temporal filtration has fundamental difficulties.

### C. Quasimodel Approach

**Idea**: Use finite quasimodel chains (already partially built in `Quasimodel/Construction.lean`) instead of infinite MCS chains. Quasimodels use Hintikka points (finite sets from a subformula closure) with defect-discharge termination.

**Feasibility**: MEDIUM-LOW. The quasimodel infrastructure exists (HintikkaPoint, quasimodel_chain_exists, defect_count termination) but it addresses a different problem: constructing finite witnesses for Until/Since obligations given a starting Hintikka point. The current `bx_until_eventuality_resolution` and `bx_since_eventuality_resolution` in Frame.lean already use this infrastructure successfully (sorry-free).

The quasimodel approach is already being used for Until/Since resolution. It cannot replace the infinite chain for temporal coherence because temporal coherence (forward_F, backward_P) requires witnesses at ARBITRARY future/past times, not just within a finite closure.

**Would preserve**: Quasimodel infrastructure is already used. But extending it to handle temporal coherence would require a fundamentally different model construction.

**Cost**: 30+ hours for a complete redesign. Would need new "infinite quasimodel" theory not present in the codebase.

**Verdict**: NOT RECOMMENDED as a replacement. The quasimodel approach is already contributing where it can (Until/Since resolution).

### D. Canonical Model with BX11-Compatible Enumeration

**Idea**: Instead of round-robin scheduling, enumerate formulas in an order that respects BX11 witness priority. If `F(psi)` and `F(chi)` are both in the MCS and BX11 says `psi`'s witness comes first, resolve `psi` first.

**Feasibility**: LOW. The 3-cycle counterexample from Report 16 shows that BX11 does NOT define a total order on F-defects. For three formulas A, B, C, it is possible that BX11 says A < B (case 1), B < C (case 1), but C < A (case 3 reversal). No linear enumeration can respect all BX11 constraints simultaneously.

**Would preserve**: Most infrastructure, but requires new chain definition.

**Cost**: INFEASIBLE due to BX11 non-transitivity.

**Verdict**: NOT RECOMMENDED. BX11 cycling is a proven obstruction.

### E. Two-Pass Construction

**Idea**: Build a "draft" chain first (with potential forward_F violations), then repair it in a second pass.

**Feasibility**: LOW. The draft chain is already built (the current `rr_fwd_chain`). The problem is that "repair" would require modifying MCS at specific indices. MCS are obtained via Lindenbaum's lemma with `.choose`, and there is no way to retroactively change the choice. The chain is defined by recursion; modifying step `n` would change all subsequent steps, invalidating previously proved properties.

**Would preserve**: Nothing (complete chain replacement).

**Cost**: 30+ hours, with uncertain outcome.

**Verdict**: NOT RECOMMENDED.

### F. Compactness-Based Argument

**Idea**: Use compactness of propositional logic to argue that if every finite prefix of the chain can satisfy forward_F, then the infinite chain can too.

**Feasibility**: VERY LOW. Compactness for propositional logic gives: if every finite subset of a theory is satisfiable, the whole theory is satisfiable. This does not directly apply because forward_F is a property of the INDEX STRUCTURE (existence of `s > n` with `psi in chain(s)`), not a propositional formula. There is no obvious way to reduce "every formula eventually appears" to a propositional satisfiability claim.

**Would preserve**: N/A.

**Cost**: Research-heavy, uncertain.

**Verdict**: NOT RECOMMENDED.

---

## Cost-Benefit of Restructuring

### What Would Be Preserved Under Any Approach

| Component | Lines | Sorry-free? | Reusable? |
|-----------|-------|-------------|-----------|
| Frame.lean (BXPoint, bx_le, witness lemmas) | 673 | Yes | In all approaches |
| TruthLemma.lean | 320 | Yes | In all approaches |
| ParametricCanonical/History/TruthLemma | ~1500 | Yes | In all approaches |
| RestrictedParametricTruthLemma | ~487 | Yes | In all approaches |
| OrderedSeedConsistency.lean | ~200 | Yes | In approaches A, D |
| Quasimodel/* | ~1816 | Yes | Already used |
| Filtration/* | ~316 | Yes | Already used |
| CanonicalChain.lean | 157 | Yes | In all approaches |
| RootScopedChain.lean lines 1-1100 | ~1100 | Yes | In approaches A, D |
| Completeness.lean | 153 | Yes | In all approaches |
| CanonicalModel.lean | ~680 | Partial (6 sorry) | Dead code |

**Total reusable sorry-free infrastructure**: ~6,400 lines.

### Restructuring Cost Estimate

| Approach | Rewrite Cost | Lines Affected | Risk |
|----------|-------------|----------------|------|
| Fix within current architecture (Strategy C or variant) | 5-15 hours | ~200 lines in RootScopedChain.lean | Medium |
| Henkin-style chain (approach A) | 10-20 hours | ~500 lines new chain definition | Medium-High |
| Filtration completeness (approach B) | 40+ hours | ~2000 lines new proof path | Very High |
| Quasimodel replacement (approach C) | 30+ hours | ~1500 lines new theory | High |
| Complete restructure | 60+ hours | ~3000+ lines | Very High |

**Recommendation**: The marginal cost of fixing the current architecture is 5-15 hours. The cost of any restructuring starts at 30 hours. The ROI of restructuring is strongly negative.

---

## The "Any Choice Works" Question

This is the KEY creative question from the assignment: can we prove that ANY choice made by `.choose` in the Lindenbaum extension must eventually resolve `psi`?

### Analysis

The chain uses `enriched_fwd_step` which wraps `resolving_enriched_fwd_exists.choose`. The `.choose` picks an arbitrary Lindenbaum extension of the seed `{beta', compound} union g_content(M)` where `beta'` is the BX11 fold result.

**Can we prove that ANY choice works?** This decomposes into:

1. **F(psi) persists**: Yes, proved. `enriched_fwd_step_preserves` shows that for any `chi in sigma_list` with `F(chi) in M`, either `chi in M'` or `F(chi) in M'`. So F-obligations are never permanently lost.

2. **psi must eventually appear directly**: This is the gap. The disjunction `psi in M' OR F(psi) in M'` allows F(psi) to persist indefinitely without psi ever appearing directly.

3. **Contradiction from permanent non-resolution**: If psi NEVER appears in the chain despite F(psi) being in every step, can we derive a contradiction? The key structural fact is:

   - F(psi) in chain(n) for all n >= t (by F-obligation constancy)
   - At psi's visit steps (n = j + k * |sigma_list|), psi IS the target of `enriched_fwd_step`
   - `enriched_fwd_step_resolves_one` guarantees SOME formula `w` is directly resolved
   - If `w != psi` every time, then BX11 Case 3 must fire for psi at every visit step

   The question is: does BX11 Case 3 firing infinitely often for psi against varying opponents lead to a contradiction?

4. **The BX11 Case 3 structural constraint**: When BX11 gives Case 3 for F(psi) and F(chi): `F(F(psi) and chi) in M`. This means the MCS believes chi's witness comes before psi's. At the NEXT visit step, psi faces a DIFFERENT opponent (the new fold compound). The MCS at that step may have different BX11 outcomes.

5. **Possible argument**: At each visit step where psi is the target and F(psi) in M_step:
   - The fold compound packages all other F-obligations
   - BX11 between F(psi) and F(compound) gives one of three cases
   - If Case 3 always fires: F(F(psi) and compound) in M_step for all visit steps
   - The Lindenbaum extension M' satisfies: F(psi) in M' (not direct) and compound in M'
   - compound in M' unpacks to: for each other chi, either chi in M' or F(chi) in M'
   - So at M': psi is NOT directly present, but F(psi) in M'
   - This is consistent -- there is no contradiction from a single step

6. **The deeper question**: Over infinitely many steps, does the perpetual non-resolution of psi contradict some global property? The BX axiom system has no explicit axiom saying "every F-obligation must eventually be resolved." The closest is BX5 (self-accumulation) and BX6 (absorption), but these govern Until structure, not bare F-obligations.

**Conclusion on "Any Choice Works"**: **No, we CANNOT prove that any choice works.** The `.choose` can legitimately pick an MCS where psi is not directly present at every step, as long as F(psi) persists. The BX axioms do not force eventual resolution through arbitrary Lindenbaum choices. The fix must come from CONTROLLING the choice (using `enriched_resolving_seed_consistent` to guarantee psi appears), not from proving that arbitrary choices work.

---

## Recommended Long-Term Strategy

### Immediate (Next Implementation Attempt)

**Strategy C (direct contradiction on existing chain)** remains the best approach, but with a refined attack vector:

1. **Assume** psi never appears in the chain (for all s > n, psi not in chain(s))
2. **Establish** F(psi) in chain(m) for all m >= n (by F-propagation, proved)
3. **At psi's visit step m**: enriched_fwd_step processes psi as target with F(psi) in M
4. **Key new insight**: At this step, `enriched_fwd_step_resolves_one` gives some `w in sigma_list` with `F(w) in M` and `w in M'`. If `w = psi`, contradiction (psi in M' = chain(m+1)). So `w != psi`.
5. **But**: `w in M'` means w was directly resolved. Since w != psi, we have a formula w that IS directly present. Over infinitely many visit steps for psi, the resolved formula w may vary. But psi is NEVER resolved.
6. **The contradiction would need to come from**: some structural property relating psi's permanent F-defect status to the behavior of other formulas. This is the unsolved mathematical question.

If Strategy C fails (5-hour cap), the fallback is:

### Medium-Term Fallback: Modified Chain with Ordered Discharge

Replace `enriched_fwd_step` with `discharge_fwd_step` that uses `enriched_resolving_seed_consistent` directly:

- At each step, find the formula with the strongest BX11 claim (even if BX11 is non-transitive, there exists a pairwise-earliest formula in any finite set -- by BX11 applied iteratively)
- Use `enriched_resolving_seed_consistent` to build a seed where this formula is GUARANTEED to appear (not just disjunctively)
- The defect count strictly decreases at each step (the resolved formula cannot regain F-defect status at the same step because it is directly present)

**Critical question**: Does the defect count STAY decreased? If the resolved formula reappears as a defect at the next step (F(psi) persists, psi might be lost), the measure is not monotone. This is Handoff 15's identified gap.

**Possible resolution**: Use a lexicographic measure on (defect_count, BX11_structure) or use the "never-resolved" count from Handoff 15 point (c). The never-resolved count |{chi in S | chi has never appeared in any chain step}| does strictly decrease at each step (at least one formula is newly resolved). Since S is finite, this terminates.

**But**: "Never appeared in any chain step" is not a property expressible within the recursion -- it requires quantifying over ALL previous steps. This may require a global invariant threaded through the recursion, which is feasible but increases proof complexity.

### Long-Term: Publication Path

Once the sorry is closed:
1. Task 95: `#print axioms` audit
2. Documentation cleanup
3. Paper writing -- the formalization would be the first Lean 4 completeness proof for Since-Until temporal logic

The architectural investment in the parametric canonical model, restricted truth lemma, and BFMCS framework is publication-worthy regardless of the specific chain fix chosen.

---

## Confidence Level

| Assessment | Confidence |
|-----------|------------|
| Architecture is fundamentally sound | 95% |
| Restructuring would NOT help | 90% |
| Strategy C can close forward_F | 35-40% |
| Modified ordered-discharge chain can close forward_F | 55-65% |
| Some approach will close forward_F within 20 hours | 70% |
| Filtration/quasimodel alternatives are viable | 10% |

The highest confidence path is the modified ordered-discharge chain with a "never-resolved count" termination measure, but this requires replacing the chain definition (Report 17 warns against this due to 30+ theorem re-proofs). The tension between "don't replace the chain" and "must control the Lindenbaum choice" is the core strategic dilemma.

**Recommended resolution**: Attempt Strategy C first (low cost, moderate probability). If it fails, accept the 30+ theorem re-proof cost and implement the ordered-discharge chain with careful infrastructure reuse.

---

## Alignment with Project Roadmap

The ROAD_MAP.md describes the goal as closing the single remaining sorry blocking `bx_completeness`. All recommendations above are aligned with this goal:

- **No new axioms** are proposed (compatible with task 95 audit)
- **No semantic changes** are proposed (reflexive Until/Since semantics stays)
- **The parametric canonical model** (D = Int) remains the completeness target
- **Publication readiness** increases with any sorry reduction

The roadmap's implicit assumption -- that the chain construction can be fixed without major restructuring -- is correct at the 70% confidence level. If it fails, the fallback (ordered-discharge chain) still uses the same BFMCS/parametric infrastructure, just with a different chain definition feeding into `dd_fmcs`.
