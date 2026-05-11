# Research Report: Task #121 (Round 2)

**Task**: Prove limitDomSubtype_Icc_finite (bounded interval finiteness)
**Date**: 2026-05-10
**Mode**: Team Research (4 teammates)
**Focus**: Reynolds 1994 "Axiomatising U and S over integer time" — full paper analysis

## Summary

Reynolds 1994 is now fully analyzed. All 4 teammates unanimously conclude: (1) Reynolds's completeness proof uses an entirely different architecture (Ehrenfeucht-Fraïssé equivalence ≡_k, expressive completeness, contemporaneous equivalence relations, lexicographic sums) that **bypasses interval finiteness entirely** — he never proves it and never needs it; (2) adopting Reynolds's bypass is **architecturally incompatible** with the ProofChecker (60-120+ hours, requires formalizing EF games, expressive completeness, and restructuring the entire discrete branch); (3) the **direct proof of `limitDomSubtype_Icc_finite` remains the correct path** (~200-400 lines, 10-20 hours).

The critical new insight from this round: **the proof cannot rely on abstract order-theoretic properties alone** (SuccOrder + PredOrder + bounded does NOT imply finite for subsets of ℚ in general). The proof MUST use properties specific to the chronicle construction — specifically, that C5 witnesses for U(⊤,⊥) permanently close adjacent pairs, preventing the ω+ω* accumulation pattern.

## Key Findings

### Primary Approach (from Teammate A)

**Reynolds never proves interval finiteness.** His completeness route is:
1. Burgess-Xu → countable, discrete, no-endpoint model M (Corollary 3)
2. Expressive completeness of U,S over Prior structures (Theorem 5)
3. Define contemporaneous equivalence ~M via "very good" subintervals (Lemma 17)
4. ~M classes don't end at gaps (Theorem 14)
5. Countable + very good → good via lexicographic sums (Lemma 16)
6. Transfer truth via ≡_k to a ℤ-interval model (Theorem 15)

**"Good" ≠ isomorphic to ℤ.** "Good" means ≡_k (Ehrenfeucht-Fraïssé equivalent at quantifier depth k) to a ℤ-interval — a model-theoretic equivalence that allows structures of different cardinality. So "good" does NOT imply finite.

**Reynolds's implicit argument (Section 8, proof of Theorem 15):** If M is not good, then not very good, so ∃ a < b with M|[a,b] not good. Then ~M has ≥2 classes in [a,b]. The first class ends at some point c (can't end at a gap by Theorem 14), but c+1 exists (discreteness) and is NOT in c's class. However, M|[c, c+1] is trivially good (2-element structure), and ~ is transitive — contradiction. **The finiteness used is only for 2-element intervals** (trivially finite).

### Alternative Approaches (from Teammate B)

**Reynolds bypass is NOT viable.** Three fundamental blockers:

| Blocker | Detail |
|---------|--------|
| Architecture mismatch | ProofChecker needs `AddCommGroup D`, `TaskFrame D`, `ShiftClosed` — concrete algebraic structure. Reynolds gives ≡_k equivalence — abstract model-theoretic agreement. |
| No Mathlib support | EF games, lexicographic sum ≡_k preservation — none exists in Mathlib v4.27.0. Estimated 800+ lines of novel infrastructure. |
| BFMCS coherence not depth-bounded | G/H/Until/Since coherence quantifies over all formulas, so ≡_k transfer cannot preserve it. |

**Positive insight:** Reynolds's Section 8 proof (lines 970-973) implicitly contains the Icc_finite argument **in disguise** — his adjacency transitivity argument ({c, c+1} trivially good → transitivity chains all bounded intervals) is precisely the mathematical content of Icc_finite, just expressed in different language.

### Gaps and Shortcomings (from Critic)

**CRITICAL: Abstract order theory is insufficient.** The set S = {1−1/2^n : n ∈ ℕ} ⊂ ℚ demonstrates that a bounded discrete subset of ℚ with SuccOrder CAN appear infinite — but fails because succ(0) would require a minimum element above 0, which {1/2^n} doesn't have. More subtly, an ω+ω* configuration (points converging to a gap L from both sides) CAN carry a valid SuccOrder on S ⊂ ℚ with infinite bounded intervals.

**Therefore:** `limitDomSubtype_Icc_finite` CANNOT be proved from `SuccOrder` + `PredOrder` + `LinearOrder` + `NoMaxOrder` + `NoMinOrder` alone. The proof MUST use properties specific to the chronicle construction.

**What prevents ω+ω* in limit_dom:** In the discrete case, the C5 condition for U(⊤,⊥) at each point x gives a witness y with the guard condition "⊥ ∈ f(w) for all w between x and y." Since ⊥ is NEVER in any MCS, this means NO domain points can exist between x and y — not just at the current stage, but at ALL future stages. This **permanently closes** each adjacent pair once the C5 witness is established, preventing accumulation.

**Available codebase properties:**

| Property | Location | What It Gives |
|----------|----------|---------------|
| `dom_new_unique` | CounterexampleElimination.lean:601 | Each step adds at most 1 new point |
| `omega_chain_dom_mono` | ChronicleConstruction.lean:314 | dom(n) ⊆ dom(n+1) |
| `limit_dom_has_succ` | ChronicleToCountermodel.lean:855 | Discrete case: each x has immediate successor |
| `limit_dom_has_pred` | ChronicleToCountermodel.lean:870 | Discrete case: each x has immediate predecessor |

### Strategic Horizons (from Teammate D)

**Strategic alignment:** The critical path 121 → 122 → sorry-free `bx_completeness` is unchanged. Reynolds confirms the math is sound but provides no shortcut.

| Approach | Effort | Risk | Verdict |
|----------|--------|------|---------|
| Direct proof of Icc_finite | 10-20 hours | Low-medium | **RECOMMENDED** |
| Reynolds bypass | 60-120 hours | High (novel infrastructure) | Not recommended |
| Hybrid (Reynolds insight + direct) | 10-20 hours | Low | Same as direct |

**Task alignment:** Task 116 (redefine G,H,F,P in terms of U,S) is validated by Reynolds (he uses U,S as primitives). Task 120 (semantic foundation for group structure) is orthogonal — Reynolds sidesteps AddCommGroup via ≡_k transfer, confirming "IsSuccArchimedean has nothing to do with AddCommGroup."

## Synthesis

### Conflicts Resolved

**Reynolds bypass viability:** All 4 teammates independently concluded the bypass is not viable. No conflict.

**Effort estimates for Reynolds bypass:** A: 500+ hours, B: 800+ lines new infrastructure, C: 500-1000+ hours, D: 60-120 hours. **Resolution:** D's lower estimate (60-120 hours) counts only the core mathematical formalization; A and C include the architectural restructuring of `ChronicleToCountermodel.lean`. All agree it vastly exceeds the direct proof effort.

**Proof strategy for direct Icc_finite:** Teammates proposed different approaches:
- A: Successor chain convergence in ℝ → contradiction
- B: Omega-chain counting (bound productive stages)
- C: Stage counting via `dom_new_unique` + counterexample enumeration
- D: Accumulation point violates no-gap property from Prior-UZ

**Resolution:** All approaches reduce to the same core fact but differ in formalization strategy. The convergence-in-ℝ argument (A, D) has a gap: the limit point L may be irrational, requiring careful handling. The stage-counting argument (B, C) avoids real analysis but requires showing productive stages are finite. **The C5 permanent-closure argument is the strongest foundation** — it directly uses the chronicle construction's discrete-case property.

### Gaps Identified

1. **Abstract order theory gap (NEW):** Cannot prove Icc_finite from abstract properties alone. Must use chronicle-specific C5 permanent closure.

2. **Convergence argument gap:** If succ chain converges to irrational L ∈ ℝ\ℚ, the contradiction isn't immediate. Need: either (a) show L ∈ ℚ (hard), (b) show L ∈ limit_dom (circular — assumes L is reachable), or (c) derive contradiction from L being an accumulation point of a discrete set (requires embedding in ℝ and topological argument).

3. **Stage stabilization gap:** Round 1 showed omega chain does NOT stabilize at finite stages in general. But in the DISCRETE case, C5 witnesses for U(⊤,⊥) permanently close adjacent pairs. The question is: does this force stabilization on bounded intervals? The answer appears YES, but the argument requires showing that the number of "open" gaps in [a,b] decreases to zero.

4. **Formalization gap:** The proof likely needs a lemma not yet in the codebase: "once x and its C5 witness y for U(⊤,⊥) are both in dom(n), no point is ever inserted between x and y at any stage m > n."

### Recommendations

**Primary recommendation:** Prove `limitDomSubtype_Icc_finite` directly using the C5 permanent-closure property:

1. **Establish the permanent-closure lemma**: For x ∈ limit_dom in the discrete case, once the C5 witness y for U(⊤,⊥) at x is placed, the interval (x.val, y.val) contains no limit_dom points — not just at the insertion stage, but at ALL future stages. This is because any new point w between x and y would require ⊥ ∈ f(w), which is impossible (⊥ is never in an MCS).

2. **Show interval stabilization**: For a ≤ b in LimitDomSubtype, show that limit_dom ∩ [a.val, b.val] = dom(N) ∩ [a.val, b.val] for some sufficiently large N. The argument: dom(N₀) ∩ [a.val, b.val] is finite (say k points). Each C5 processing for U(⊤,⊥) at a point in this interval either finds the witness already present or adds one new point. After all k initial points have their C5 processed (which happens at finite stages since the enumeration is surjective), PLUS any C5 processing for newly added points, the interval is fully partitioned into permanently closed adjacent pairs. The finiteness follows because each permanent closure reduces the "open territory" and the construction is monotone.

3. **Conclude finiteness**: Since limit_dom ∩ [a.val, b.val] ⊆ dom(N) for some N, and dom(N) is a Finset, the intersection is finite.

**Estimated effort**: 200-400 lines, 10-20 hours. The permanent-closure lemma is the key new contribution; the rest follows from existing codebase infrastructure.

**Alternative if stabilization is too hard to prove directly**: Use the convergence argument (embed in ℝ, derive accumulation point, use PredOrder to get contradiction). This requires ~50-100 lines of Mathlib real analysis but avoids reasoning about the construction stages. The PredOrder contradiction at the accumulation point L works if L ∈ limit_dom (pred(L) exists, but infinitely many points between pred(L) and L, contradiction).

## Teammate Contributions

| Teammate | Angle | Status | Confidence |
|----------|-------|--------|------------|
| A | Primary (Reynolds paper analysis) | completed | high |
| B | Alternatives (bypass viability) | completed | high |
| C | Critic (gaps, counterexamples) | completed | medium-high |
| D | Horizons (strategic alignment) | completed | high |

## References

### Reynolds 1994 (Now Obtained)
- Reynolds, M. "Axiomatising U and S over integer time." ICTL 1994, LNCS 827, pp. 117-132.
- Section 8: "Using Contemporaneity on the Integers" — Theorem 15, Lemma 16, Lemma 17
- Key result: Countable + discrete + no-endpoints + Prior-UZ/SZ → ≡_k ℤ-interval (Theorem 15)
- Proof strategy: contemporaneous equivalence + lexicographic sums, NOT interval finiteness

### Codebase References
- `ChronicleToCountermodel.lean:1059-1064`: The sorry location
- `ChronicleToCountermodel.lean:1074-1111`: IsSuccArchimedean proof (uses Icc_finite)
- `ChronicleToCountermodel.lean:855-870`: limit_dom_has_succ/pred (discrete case)
- `ChronicleConstruction.lean:551-554`: limit_dom definition (union of finite stages)
- `ChronicleTypes.lean:380`: `dom : Finset Rat` (finite domains at each stage)
- `CounterexampleElimination.lean:601`: dom_new_unique (at most 1 new point per step)
- `ChronicleConstruction.lean:314`: omega_chain_dom_mono (domain monotonicity)

### Prior Research
- Round 1 report: `specs/121_prove_limit_dom_interval_finite/reports/01_team-research.md`
- Task 120 research: Confirms "IsSuccArchimedean has nothing to do with AddCommGroup"
