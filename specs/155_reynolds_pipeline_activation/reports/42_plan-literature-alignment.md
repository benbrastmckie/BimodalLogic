# Plan v41 vs GHR93 Literature Alignment Review

**Task**: 155 (reynolds_pipeline_activation)
**Date**: 2026-05-28
**Scope**: Quality gate review of plan v41 (41_stavi-uba-plan.md) against GHR93 prior art extractions

---

## 1. Phase S1 (Bridge Lemma) Alignment

**Assessment: ALIGNED**

The plan describes `nf_2var_from_interval_data` as the "bridge lemma" connecting agreement on 1-variable types, ordering, interval types, and types above/below to 2-variable NF equality. This matches GHR93 Proposition 7 + Lemma 11.

**GHR93 Lemma 11** (report 08, Section 2.4): Duplicator wins G_{n;r}(M,xy; N,x'y') iff M_r and N_r agree on all (n;r)-decomposition formulas. The decomposition formulas capture exactly the data that `nf_2var_from_interval_data` takes as hypotheses: 1-variable NFs at endpoints (h_nf_x, h_nf_t), ordering (h_order_xt), interval types (h_interval_above, h_interval_below), and types outside the interval (h_above_max, h_below_min).

**Key verification**: The bridge lemma is a genuine GHR93 result, not a formalization artifact. The hypothesis signature at StaviCompleteness.lean:1853-1870 directly encodes the hypotheses of Lemma 11's decomposition formula agreement.

**Concern**: The plan estimates 200-500 lines (S1 total: 4-8 hours). Report 41 estimates 200-500 lines for the root sorry alone, plus 100-200 for the chained sorry. The plan's S1.2-S1.5 subtask decomposition (100-150 + 50-80 + 50-100 + 50-100 = 250-430 lines) is reasonable but at the optimistic end. The connection from `interval_nf_types` to `decomposition_agreement` (S1.2) is the least well-understood step.

**No discrepancies found.**

---

## 2. Phase S2 (Depth Bound) Alignment

**Assessment: PARTIALLY ALIGNED -- depth bound analysis contains a known unresolved tension**

### 2.1 The stavi_depth bound

The plan (S2.1) proposes proving `stavi_depth A <= 2*k` for the output of `nf_characterizable_by_stavi` at depth k. The depth analysis is:
- Base case k=0: depth 0 (conjunction of atom literals)
- Inductive case k+1: each `exist_sf` uses `std_untl`/`std_snce` adding +2, with guard formulas built from char_k at depth <= f(k)
- f(k+1) = f(k) + 2, so f(k) = 2*k

This analysis is plausible but **not verified in Lean**. Report 41 confirms: "The formula is NOT the rank_type formula from TypeFormulas.lean -- it is a different construction that characterizes NF satisfaction rather than bounded-depth formula agreement." The exact depth of the classically chosen formula from `nf_2var_existence_characterizable` depends on the internals of `nf_exist_sf_guarded`, which uses `std_untl`/`std_snce`. The bound f(k) = 2*k is an estimate, not a proved fact.

### 2.2 The critical tension: stavi_depth(B) vs transfer rank

The plan identifies this tension explicitly (S3.2 lines 197-204, and the Depth-Agreement Analysis on lines 370-379) but does not fully resolve it. The scenarios are:

| stavi_depth(B) | phi = U(B,sf_top) depth | Transfer needs | delta needed |
|----------------|-------------------------|----------------|-------------|
| <= r | r + 2 | r + 2 <= r + delta | delta >= 2 |
| = 2*r | 2*r + 2 | 2*r + 2 <= r + delta | delta >= r + 2 |

With the current architecture where `hd : 2 <= delta`, only the first row works. If B has depth 2*r, delta=2 is insufficient for r >= 1.

**GHR93's approach** (report 08, Section 5): GHR93 defines B = X_{alpha_n}, which is the conjunction of all rank-r formulas true at alpha_n. By definition, stavi_depth(B) = r (it is literally the set of depth-<= r formulas). GHR93 uses tau at rank r+4, and U(B, sf_top) has rank r+1 <= r+4.

**The gap**: `nf_characterizable_by_stavi` does NOT produce the rank_type formula. It produces a formula characterizing a specific NormalForm, with potentially much larger depth. The `rank_type` (TypeFormulas.lean:356) IS the GHR93 X_{alpha_n}, but it is a SET of formulas, not a single formula. To use it as B in U(B, sf_top), one would need to convert the set to a single formula (e.g., via conjunction), which requires enumerating all depth-<= r StaviFormulas -- but StaviFormula is not Fintype (report 41, Section 5).

### 2.3 Plan's resolution strategy

The plan (S3.2 lines 200-204) acknowledges this gap and proposes multiple resolutions:
1. Use `rank_type` approach from TypeFormulas.lean (depth <= r by construction)
2. Fall back to `nf_characterizable_by_stavi` at depth r with delta >= d+2-r
3. "FINAL DECISION" (line 204): call `nf_characterizable_by_stavi` at depth r, accept whatever stavi_depth comes out, and ensure delta is large enough

The "FINAL DECISION" essentially defers the problem to runtime: "set delta >= d + 2 - r" where d is the actual stavi_depth. But the current code has `hd : 2 <= delta` as a fixed constraint, and Theorem6.lean passes delta=4 (rank-varying) or delta=2 (uniform). If d = 2r, then delta >= r+2 is needed, which means delta=4 only works for r <= 2.

**Discrepancy**: The plan says "GHR93 uses delta = 4*n where n is the number of backward rounds; at the top level of the induction, delta can be made as large as needed." This is **incorrect**. GHR93 uses a FIXED delta=4 per induction step (rank peels off by 4 at each step: r+4(n+1) -> r+4 for sigma/tau). The total rank excess is 4*(n+1), but at each step the strategies are at rank r+4, not r+4*n.

**Recommendation**: This is the plan's most significant weakness. See Section 4 (Rank Sufficiency) for the full analysis.

---

## 3. Phase S3 (U(B,A) Case II) Alignment

**Assessment: PARTIALLY ALIGNED -- correct high-level structure, but the "A" formula is wrong and rank arithmetic is unresolved**

### 3.1 Overall structure

The plan's Case II follows GHR93's construction:
1. Build B for p_n (the rank-r type formula) -- correct
2. Form phi = U(B, sf_top) -- **sf_top is wrong; see Section 5**
3. Show phi holds at a_init(n-1) in N -- correct
4. Transfer phi through tau -- correct approach
5. Extract witness z = e_n -- correct
6. sel_pn_ord trivial from Until ordering -- correct

This matches report 40 (Section 1) and report 22 (Section 4.4-4.5).

### 3.2 e_n from U(B,A) witness -- CORRECT

The plan correctly identifies that e_n comes from U(B,A) transfer through tau, NOT from the forward game. This matches GHR93 verbatim (report 40, Section 1):

> "Duplicator defines e_n to be such a z, completing her move."

The plan explicitly states (line 19): "GHR93 constructs e_n from U(B,A) witness z transferred through tau. sel_pn_ord is trivial."

### 3.3 sel_pn_ord trivial -- CORRECT

Report 40 (Section 2) confirms:
```
resp_tau(k) <= resp_tau(n-1) < z = e_n
```
The first inequality is from tau's order preservation, the second from the Until witness definition. The plan's S3.4 correctly describes this as a ~20-30 line proof.

### 3.4 Round 2 handling -- PARTIALLY CORRECT

The plan's S3.5 describes the round 2 case split:
- Challenge in (resp_tau(k), resp_tau(k+1)): use tau -- **correct**
- Challenge in (resp_tau(n-1), e_n): use A-condition -- **correct in intent, but A = sf_top means no constraint, which is NOT what GHR93 says**
- Challenge outside [x, y]: endpoint conditions -- **correct**
- Challenge at e_n / resp_tau(k): point agreement from B and tau -- **correct**

GHR93 (report 22, Section 4.6) specifies:
- t in (e_{n-1}, e_n): "M |= A(t). By definition of A there is t' in (alpha_{n-1}, alpha_n) with N |= X_{t'}(t)."

This A is X_{(alpha_{n-1}, alpha_n)}, the interval type formula -- NOT sf_top. See Section 5.

### 3.5 Cases III and IV -- ACKNOWLEDGED BUT NOT DETAILED

The plan (S4.1) mentions Cases III/IV but does not detail how they differ from GHR93. Report 08 (Section 6) gives:
- Case III: gap defined on LEFT by D; uses left(B, D) at rank r+2, then U(left(B,D), A) at rank r+3
- Case IV: gap NOT defined on left; uses right(B, D) and a compound formula at rank r+3

Both require formulas of rank up to r+3, transferred through tau at rank r+4. With the current delta=2 (tau at r+2), neither can transfer rank-(r+3) formulas.

**Risk**: The plan says Cases III/IV "mirror Case II" (S4.1 line 267) but GHR93's Cases III/IV require rank r+4 for formula transfer, just like Case II. The plan does not address this.

### 3.6 Delete old tau_left/tau_right -- CORRECT

The plan (S3.6) correctly identifies the old infrastructure for deletion. The current CaseAnalysis.lean (lines 1368-1378) constructs tau_left and tau_right as sub-interval games, then uses resp_mod for the equality case. This entire approach is superseded by U(B,A).

### 3.7 Theorem6.lean rank promotion -- PARTIALLY ADDRESSED

The plan (S3.7) identifies two sorry sites:
- Line 124: IH lambda at delta=2 -- the plan says this may require "the ambient high-rank forward game restricted to sub-intervals"
- Line 325: succ case in rank-varying -- "requires constructing backward games at a higher rank from forward games at a lower rank"

Both of these are manifestations of the same fundamental issue: how to construct the IH at the right rank. The plan does not provide a concrete proof strategy beyond "strategy restriction from the ambient game."

---

## 4. Rank Sufficiency: Is delta=2 Enough?

**Assessment: MISALIGNED -- delta=2 is almost certainly insufficient; delta=4 is needed**

This is the most important finding of this review.

### 4.1 GHR93's rank structure (definitive, from report 08)

```
Forward game: G_{4+3n; r+4(n+1)}(M, xy; N, x'y')
IH applied at base rank r+4: (*_n) at r+4 gives backward at r+4
sigma, tau: G_{n; r+4}(N, sub-intervals)
```

Key formulas and their ranks:
- C' (Claim 1): rank r+1
- B = X_{alpha_n}: rank r (depth <= r by definition)
- U(B, A): rank r+1
- left(B, D) (Case III): rank r+2
- U(left(B,D), A) (Case III): rank r+3
- compound formula (Case IV): rank r+3

All transfer through tau at rank r+4. The slack of +4 per induction step is NOT arbitrary -- it is precisely calculated to accommodate Cases III and IV.

### 4.2 The plan's delta=2

With delta=2, tau operates at rank r+2. Formula transfer is limited to depth <= r+2.

| Formula | Depth | Transfers at r+2? | Transfers at r+4? |
|---------|-------|--------------------|--------------------|
| C' (Claim 1) | r+1 | Yes | Yes |
| U(B, sf_top) where B depth = r | r+2 | Marginal (= r+2) | Yes |
| U(B, sf_top) where B depth = 2r | 2r+2 | No (r >= 1) | No (r >= 2) |
| left(B, D) (Case III) | r+2 | Marginal | Yes |
| U(left(B,D), A) (Case III) | r+3 | No | Yes |
| Case IV compound | r+3 | No | Yes |

**Even with delta=4, if B has depth 2r, Cases II-IV all fail for r >= 2.** The plan's depth-agreement gap is fundamental.

### 4.3 The real resolution

GHR93 uses B = X_{alpha_n} with depth exactly r (it is the conjunction of ALL depth-<= r formulas true at alpha_n). This is not `nf_characterizable_by_stavi` -- it is `rank_type` from TypeFormulas.lean.

The resolution requires BOTH:
1. **delta = 4** (or at least 4, to handle Cases III/IV)
2. **B at depth <= r** (using rank_type or equivalent, NOT nf_characterizable_by_stavi at depth r which gives depth 2r)

The plan partially recognizes (1) in the Depth-Agreement Analysis (lines 370-379) but treats delta as adjustable. In reality, the Theorem6.lean induction structure fixes delta. The rank-varying version uses delta=4 (line 326), but the sorry at line 325 is precisely the obstacle.

The plan does NOT adequately address (2). The "FINAL DECISION" (line 204) to use `nf_characterizable_by_stavi` at depth r and "set delta >= d + 2 - r" is not implementable with the current architecture where delta is a fixed parameter of the induction.

### 4.4 Recommendation

The plan should:
1. Commit to delta=4 (not delta >= 2) as the target for sigma/tau rank
2. Commit to constructing B with depth <= r (either via rank_type conversion or by proving that nf_characterizable_by_stavi at a suitable depth gives depth <= r)
3. Address the sorry at Theorem6.lean:325 as a prerequisite for Phase S3, not a consequence

---

## 5. The "A" Formula Question

**Assessment: MISALIGNED -- A = sf_top is incorrect; A = X_{(alpha_{n-1}, alpha_n)}**

### 5.1 GHR93's A

Report 22 (Section 3) gives the verbatim GHR93 text:

> "Define B = X_{alpha_n}, [...] Now clearly N_r |= U(B, A)(alpha_{n-1}): alpha_n is a witness to this."

And from report 22, Section 4.0:
> "A = X_{(alpha_{n-1}, alpha_n)} [rank r formula; interval type of (alpha_{n-1}, alpha_n) in N]"

A is the interval type formula X_{(alpha_{n-1}, alpha_n)} -- the disjunction of X_v for all points v in the open interval (alpha_{n-1}, alpha_n). This has rank r by definition (GHR93 Definition 8.8, report 08 Section 1.4).

### 5.2 Why sf_top is wrong

With A = sf_top:
- U(B, sf_top) says: "there exists z > e_{n-1} with B(z), and sf_top holds at all intermediate points"
- sf_top is always true, so the intermediate-point condition is vacuous
- This gives z with B(z), but provides NO information about points in (e_{n-1}, z)

With A = X_{(alpha_{n-1}, alpha_n)}:
- U(B, A) says: "there exists z > e_{n-1} with B(z), and every point t in (e_{n-1}, z) has the same rank-r type as some point in (alpha_{n-1}, alpha_n)"
- This is precisely what Round 2 needs for the sub-case t in (e_{n-1}, e_n)

GHR93 (report 22, Section 4.6):
> "If t in (e_{n-1}, e_n) then M |= A(t). By definition of A there is t' in (alpha_{n-1}, alpha_n) with N |= X_{t'}(t). Duplicator can then choose any such t' as her response."

Without A = X_{(alpha_{n-1}, alpha_n)}, Duplicator has no way to handle round-2 challenges in (e_{n-1}, e_n). The plan's S3.5 says "A = sf_top holds trivially (no constraint on intermediate points)" -- this is correct that sf_top holds trivially, but it means the formula provides no useful information for Round 2.

### 5.3 Similarly for t > e_n

GHR93 handles t > e_n using C (the continuation formula):

> "If y > t > e_n then certainly t > c, so M |= C(t). By definition of C there is t' > alpha_n with N |= X_{t'}(t)."

C = X_{(alpha_n, y')} is the interval type formula for the region above alpha_n. This is also NOT sf_top.

### 5.4 Impact on the plan

Using A = sf_top makes U(B, sf_top) a weaker formula than U(B, A). The witness z still exists (B(z) and "true at all intermediate points"), but the round-2 case for t in (e_{n-1}, e_n) requires a SEPARATE argument to find a matching t' in (alpha_{n-1}, alpha_n). This argument would need to use the interval type agreement from tau's winning condition rather than from A.

This is not necessarily fatal -- one could argue that tau's winning condition already provides interval type information for the sub-interval (d, y')/(c, y). But it makes the proof strictly harder and diverges from GHR93.

### 5.5 Recommendation

Replace A = sf_top with A = X_{(alpha_{n-1}, alpha_n)}. This is the `interval_types` from TypeFormulas.lean:366. Like B, encoding A as a single formula faces the same StaviFormula-is-not-Fintype issue, but the semantic content (interval type agreement) is available from tau's winning condition. The plan should either:
1. Materialize A as a StaviFormula (hard: requires encoding a disjunction over an infinite type)
2. Work at the semantic level: use tau's formula preservation at rank r+4 to transfer the PREDICATE "has the same interval type" rather than a specific formula (more natural in the Lean encoding)

---

## 6. Missing Elements

### 6.1 The b, b' supremum points

GHR93 defines b = sup{t in (x,y) : M |= B(t)} and b' similarly. The plan mentions b, b' only in S3.2 (lines 193-198) as part of the analysis but does not plan to construct them. Report 22 (Section 4.1) notes: "The current code does NOT define b, b'. Instead, it works directly with the interval [d, y'] / [c, y] via tau."

GHR93 uses b, b' to bound the region:
- e_n = z < b (z is in the B-region)
- tau plays on [d-bar, b'] / [c, b], not [d-bar, y'] / [c, y]

The plan uses tau on [d, y'] / [c, y], which is a larger interval. This is mathematically valid -- any strategy on the larger interval restricts to the smaller one (report 22, Section 4.2 confirms this). However, it means the plan relies on the witness z being found below y rather than below b. Since U(B, A) gives z > e_{n-1} with B(z), and we only need z in [c, y], this should be fine -- but the plan should explicitly verify that z can be found in [c, y] (not just that z exists somewhere).

**Risk: LOW.** The extended interval [d, y'] is at least as large as [d, b'], so the strategy applies.

### 6.2 Claim 2 (strategy restriction via Claim 1)

GHR93 derives sigma and tau via Claim 2, which uses Claim 1 to show that the forward game restricted to sub-intervals produces strategies on [x, c] vs [x', d-bar] and [c, b] vs [d-bar, b']. The plan (S3 overview, lines 183-184) says this is done via `SplitPointProps`, which already contains sigma and tau. The Claim 1/Claim 2 dependency is handled by `obtain_split_point_props` in SplitPoint.lean.

This is correct -- the existing `SplitPointProps` structure encapsulates the Claim 1 -> Claim 2 -> sigma/tau derivation.

### 6.3 The n=0 boundary case

GHR93 (report 22, Section 3): "if n = 0 we take alpha_{-1} to be d-bar and (see below) e_{-1} to be c."

When n=0, there is no a_{n-1}. GHR93 uses d-bar as the left boundary. The plan does not explicitly handle this case. In the Lean code, when n=0, `a_init` is an empty function (Fin 0 -> ...), and resp_tau is also empty. The U(B, A) transfer would be at the boundary point c/d rather than at resp_tau(n-1). The plan should verify that this boundary case is handled.

**Risk: MEDIUM.** Boundary cases are a common source of sorries in this codebase.

### 6.4 GHR93's h_surj threading

The plan (S2.2-S2.3) correctly identifies that `nf_characterizable_by_stavi` requires `h_surj` (atomMap surjectivity) and plans to thread it through `ghr93_inductive_step` and Theorem6.lean. This is mechanical but necessary. The plan's estimate (20-30 lines each) is reasonable.

However, if the plan switches away from `nf_characterizable_by_stavi` to a `rank_type` approach (as suggested in Section 4), h_surj threading may become unnecessary.

---

## 7. Dependency Correctness

**Assessment: MOSTLY CORRECT**

### 7.1 S1 -> S2 dependency

S2 depends on S1 because the stavi_depth bound (S2.1) can only be verified on a sorry-free `nf_characterizable_by_stavi`. This is correct.

However, S2.2-S2.3 (h_surj threading) does NOT depend on S1. It is purely a signature change. The plan could parallelize h_surj threading with S1 work.

### 7.2 S2 -> S3 dependency

S3 depends on S2 for: (a) the stavi_depth bound (needed to know whether B transfers through tau), and (b) h_surj availability. Both are correct.

### 7.3 Hidden dependency: Theorem6.lean sorry (line 325)

The plan places Theorem6.lean sorry closure in S3.7, AFTER the Case II rewrite (S3.1-S3.5). But the Theorem6.lean sorry at line 325 is the IH construction for the rank-varying version -- it is what provides delta=4 for sigma/tau. Without this sorry being closed, sigma/tau are at best at delta=2 (from the uniform-rank version), which may be insufficient.

**This is a critical ordering issue.** The plan should either:
1. Close Theorem6.lean:325 BEFORE S3.1-S3.5 (as a prerequisite), or
2. Accept delta=2 for the initial implementation and upgrade to delta=4 later

The plan currently places them in the same phase (S3), which makes the dependency implicit but not clearly ordered.

---

## 8. Risk Assessment

### 8.1 Highest risk: Depth-agreement gap (stavi_depth(B) vs transfer rank)

**Severity: HIGH. Likelihood: HIGH.**

If `nf_characterizable_by_stavi` at depth r produces a formula with stavi_depth 2r, then U(B, sf_top) has depth 2r+2, and no fixed delta suffices for all r. This is the same blocker documented in report 38 (equality-case-research.md, Section 5).

**Mitigation**: The plan's fallback (line 377-378) is to use `rank_type` from TypeFormulas.lean. This gives depth <= r by construction. But converting rank_type (a SET) to a single formula requires either Classical.choice (opaque) or explicit enumeration (impossible for StaviFormula).

The real mitigation is to work at the semantic level: instead of materializing B as a formula and transferring U(B, A) literally, use tau's formula preservation to argue that the PREDICATE "has the same rank-r type" transfers. This avoids the depth question entirely but requires a different proof architecture than what the plan describes.

### 8.2 Medium risk: A = sf_top vs A = X_{(alpha_{n-1}, alpha_n)}

**Severity: MEDIUM. Likelihood: HIGH (it IS wrong).**

Using A = sf_top is definitively wrong per GHR93. The plan must either use the correct A or provide an alternative argument for the round-2 case t in (e_{n-1}, e_n). The alternative (using tau's interval-type preservation directly) is feasible but adds complexity.

### 8.3 Medium risk: Cases III/IV require rank r+3 formula transfer

**Severity: MEDIUM. Likelihood: HIGH if delta=2.**

Cases III and IV use formulas of rank up to r+3 (report 08, Section 6). With tau at rank r+2 (delta=2), these cannot be transferred. With delta=4, they transfer fine.

### 8.4 Lower risk: n=0 boundary case

**Severity: MEDIUM. Likelihood: MEDIUM.**

The n=0 case (no a_{n-1}) is not explicitly handled in the plan. When n=0, U(B,A) is evaluated at d-bar (not resp_tau(n-1)), and the Until witness gives e_0 directly.

### 8.5 Lower risk: Bridge lemma effort

**Severity: LOW-MEDIUM. Likelihood: LOW.**

The bridge lemma (`nf_2var_from_interval_data`) is substantial (200-500 lines) but the infrastructure exists. The plan's decomposition (S1.2-S1.5) is reasonable. The fallback (axiomatize + return later) is available if needed.

---

## 9. Recommendations

### R1: Commit to delta=4 (CRITICAL)

The plan must commit to delta=4 for sigma/tau, matching GHR93. The current waffling between delta >= 2 and "adjust delta as needed" is not implementable. Concretely:
- Close Theorem6.lean:325 (rank-varying IH construction) as a prerequisite for Phase S3
- Use the rank-varying version (`ghr93_forward_to_backward_rank_varying`) as the primary entry point
- SplitPointProps already supports delta=4 via the parameterized structure

### R2: Resolve the B-formula construction (CRITICAL)

The plan must choose one of:
1. **Prove stavi_depth(nf_characterizable_by_stavi output at depth r) <= r**: This would require showing that the classically chosen formulas have tightly bounded depth. This seems unlikely given the 2*k growth estimate.
2. **Use rank_type directly**: Convert the rank_type set to a formula via Classical.choice on the existence of a conjunction. Since there are finitely many inequivalent formulas of rank <= r (GHR93 Section 1.1), this is mathematically justified.
3. **Work at the semantic level**: Instead of materializing B, use tau's formula preservation at rank r+4 to argue: "any depth-<= r formula A true at alpha_n is also true at the witness z." This avoids constructing a single formula B altogether.

Option 3 is the most natural for the Lean encoding and avoids the depth question entirely. The plan should evaluate this option.

### R3: Fix A = sf_top to A = X_{(alpha_{n-1}, alpha_n)} (HIGH)

Either:
1. Materialize A as a formula (same challenges as B), or
2. Work semantically: when a round-2 challenge t falls in (e_{n-1}, e_n), use tau's interval-type preservation to find a matching t' in (alpha_{n-1}, alpha_n). This does not require A as a formula.

Option 2 is again more natural for the Lean encoding.

### R4: Address the n=0 boundary (MEDIUM)

Add explicit handling of the n=0 case where alpha_{-1} = d-bar and e_{-1} = c. This may require a separate branch in the proof.

### R5: Reorder Theorem6.lean:325 (MEDIUM)

Move the closure of Theorem6.lean:325 (rank-varying IH) earlier in Phase S3, or make it a prerequisite. Without it, the delta=4 architecture is not available.

### R6: Verify Cases III/IV rank requirements (MEDIUM)

Explicitly check that the Cases III/IV sorry (CaseAnalysis.lean:3350) does not need rank r+3 formulas. If it does, delta=4 is required there too.

---

## 10. Summary Table

| Phase | Alignment | Key Issue | Severity |
|-------|-----------|-----------|----------|
| S1 (Bridge Lemma) | ALIGNED | None | -- |
| S2 (Depth Bound) | PARTIALLY ALIGNED | stavi_depth(B) may be 2r not r | HIGH |
| S3 (U(B,A) Case II) | PARTIALLY ALIGNED | A = sf_top is wrong; rank arithmetic unresolved | HIGH |
| S4 (Cases III/IV) | ACKNOWLEDGED | Rank r+3 formulas need delta=4 | MEDIUM |
| S5 (Verification) | ALIGNED | -- | -- |
| Rank sufficiency | MISALIGNED | delta=2 insufficient for GHR93; need delta=4 | HIGH |
| "A" formula | MISALIGNED | sf_top is wrong; need interval type | HIGH |
| n=0 boundary | MISSING | Not explicitly handled | MEDIUM |
| Theorem6 ordering | PARTIALLY ALIGNED | Sorry 325 should be prerequisite, not consequence | MEDIUM |

**Overall assessment**: The plan correctly identifies the GHR93 U(B,A) construction as the right approach and correctly identifies that e_n comes from the Until witness (not the forward game). However, it has two critical gaps: (1) the rank arithmetic is not fully resolved (delta=2 is insufficient; delta=4 is needed), and (2) A = sf_top is wrong (should be the interval type formula). Both are fixable but require plan revision before implementation begins.
