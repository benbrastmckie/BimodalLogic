# Teammate D (Horizons): Strategic Direction and Literature Analysis

**Task**: 155 (Reynolds Pipeline Activation)
**Date**: 2026-05-22
**Role**: Strategic alignment, literature context, long-term direction
**Confidence Level**: HIGH for literature analysis, MEDIUM for strategic recommendations

---

## Key Findings

### 1. The GHR93 Game Approach vs. GHR94 Separation Approach — Two Completely Different Proof Strategies

The project is implementing the GHR93 **game-theoretic** proof (EF games, Theorem 6, Claim 1). However, GHR94 Vol 1 Chapter 10 presents an entirely different proof strategy — **syntactic separation** — that achieves expressive completeness of {U,S} over integer time WITHOUT EF games.

**GHR94 Ch10 separation method** (for integer time):
- Works by syntactically pulling U out of S (and vice versa) through 8 elimination cases
- Proceeds by induction on "junction depth" (alternation of U/S nesting)
- The proof is entirely syntactic/combinatorial — no game theory, no rank-r structures, no infimum constructions
- Result: Theorem 10.2.9 (Separation) + Theorem 10.2.10 (Expressive Completeness over ℤ)

**Critical distinction**: The GHR93 game approach handles GENERAL linear time (with gaps). The GHR94 Ch10 separation approach handles SPECIFIC flows (integers, Dedekind complete). For integer time specifically, the separation approach is FAR simpler.

**However**: The project needs expressive completeness for Prior structures (not just integers), which is where the gap elimination enters. The Reynolds pipeline IS needed — but only after establishing expressive completeness of {U,S,U',S'} over general linear time (which the Stavi connectives provide).

### 2. GHR93 Claim 1 — The Exact Proof from the Paper

The GHR93 paper gives the Claim 1 proof in ~5 lines (p.116):

> **Claim 1.** Consider a play of G_{m;r'}(M, xy; N, x'y') for arbitrary r' ≥ r, m ≥ 1 in which Ǝ uses a winning strategy. Let V begin by choosing c plus m-1 other points, and let Ǝ's response to c be d. Then d = d̄.
>
> **Proof.** As the strategy is winning, any rank r' temporal formula satisfied by one of V's choices must also be satisfied by the corresponding choice of Ǝ. Now the rank r+1 formula C' = ¬C ∨ K⁻(¬C) satisfies M_r ⊨ C'(c). Hence also N_r ⊨ C'(d), so d ≤ d̄. If d < d̄ then V can choose d' ∈ (d̄, y') with N ⊨ ¬C(d'). Ǝ now has no winning response, a contradiction. Hence d = d̄.

The key insight: C' = ¬C ∨ K⁻(¬C) where:
- C is the rank-r formula defining the continuation set
- K⁻(¬C) = ¬S(⊤, ¬(¬C)) = ¬S(⊤, C) means "C does NOT hold arbitrarily close from the past"
- C' has rank r+1 (not r+2 as the plan states for the Lean depth)

The proof has TWO directions:
1. **d ≤ d̄**: C'(c) holds in M (c = inf of continuation set). By rank-(r+1) game, C'(d) holds in N. C'(d) means ¬C(d) ∨ K⁻(¬C)(d). The K⁻ part means C fails cofinally below d. Combined with the infimum definition of d̄, this gives d ≤ d̄.
2. **d̄ ≤ d (by contradiction)**: If d < d̄, then d̄ is strictly inside the continuation set where C holds. V can find d' > d̄ with ¬C(d'). Since d < d̄ < d', V chooses d' in round 2. Ǝ must respond with some e in (c, y) where ¬C(e). But c = inf of continuation set, so C holds on (c, y). Contradiction.

**For the Lean formalization**: The paper uses r+1 rank. The project's `stavi_depth` computation gives r+2 for `neg(std_snce(neg(base .bot), D))` because `stavi_depth(std_snce A B) = max(depth A, depth B) + 2`. This is why the plan bumped h_fwd_r1 from r+1 to r+2 — the discrepancy is expected and correct.

### 3. The Density Question — A Critical Finding

The Round 14 handoff raised a concern: h_d_unique may be false for discrete orders with few predecessors, because the pigeonhole chain requires K+1 failure points.

**This concern is VALID but may be moot.** GHR93's Theorem 6 proof is stated for GENERAL linear temporal structures (Section 8, p.113). The proof does NOT assume density. However, the Lean formalization uses `obtain_split_point_props` which constructs an infimum of the continuation set. The paper's infimum c = inf{t ∈ [x,y] : M ⊨ C(u) for all u ∈ (t,y)} is well-defined in any linear structure — it doesn't require density.

**The key resolution**: The paper's proof does NOT use a pigeonhole argument. The paper constructs C' = ¬C ∨ K⁻(¬C) directly from C (the continuation formula). No pigeonhole, no chain, no density assumption needed. The pigeonhole construction (`pigeonhole_definable_formula`) is from a DIFFERENT part of the codebase — it's used to find a SINGLE formula D that characterizes the continuation set. But in the GHR93 proof, C itself IS that formula — it's defined as a rank-r formula (using X_t notation for type formulas) and its failure characterizes leaving the continuation set.

**Recommendation**: Abandon the pigeonhole approach for h_d_unique. Instead, follow GHR93 literally:
1. C is already available as a rank-r formula (the continuation predicate)
2. Construct C' = ¬C ∨ K⁻(¬C)
3. Prove C'(c) in M (from infimum properties)
4. Transfer via rank-(r+2) game to get C'(d) in N
5. Derive d ≤ d̄ from C'(d)
6. Derive d̄ ≤ d by contradiction (if d < d̄, V exploits ¬C above d̄)

### 4. Reynolds 1994 Gap Elimination — Self-Contained and Game-Free

Reading Reynolds 1994 Section 7 (Lemmas 6-14) carefully:

**The gap elimination proof is largely game-free.** It uses:
- Expressive completeness of {U,S} over Prior structures (Theorem 5 — depends on Stavi result)
- Prior-U/S axioms (no definable gaps)
- Model surgery: replace a bad interval by a single equivalence class
- Induction on formula construction for truth preservation (Lemma 12)

**Lemma 12 case count**: 7 cases for U(A,B) forward direction, 6 cases for backward. S cases are dual. Total: ~26 cases but many are trivial (direct IH application). The hard cases involve the bad interval and use Lemmas 6, 9, 11 for transfer.

**The gap elimination is the MOST SELF-CONTAINED part of the entire pipeline.** Once Theorem 5 (US expressively complete over Prior) is proved, Lemmas 6-14 only use standard temporal logic and Prior axiom properties. No EF games, no ranks, no decomposition formulas.

**Estimated effort**: 6-8 hours for Phases 6A+6B is reasonable. The main risk is Lemma 12 case explosion, but S cases are perfectly dual to U cases.

### 5. State of the Art — No Existing Formalizations

**Lean 4 temporal logic projects (found)**:
- **LeanLTL** (ITP 2025, UCSC Formal Methods): Unifying framework for LTL in Lean 4. Handles LTL syntax+semantics but does NOT cover Until/Since expressive completeness or EF games. Focuses on trace-based reasoning with embedded Lean expressions.
- **LeanearTemporalLogic** (GitHub): Basic LTL formalization — syntax, semantics, transition systems. No completeness proofs.
- **Lentil** (verse-lab): TLA (Temporal Logic of Actions) in Lean 4. Different formalism entirely.

**Proof assistant formalizations of related results**:
- **Obendrauf 2024** (in this project's literature): Coalition Logic completeness in Lean 4. Shows best practices for modal logic formalization but no temporal operators.
- **Borel determinacy in Lean** (Manthe 2025): Game-theoretic proof in Lean using well-founded induction. Potentially relevant patterns for EF game strategies.
- **No formalization of Stavi connectives, EF games for temporal logic, or gap elimination exists in ANY proof assistant** (Lean, Coq, Isabelle, etc.)

**This project would be the FIRST formal verification of:**
- Stavi expressive completeness (GHR93 Theorem 3)
- EF games for temporal logic
- Reynolds gap elimination
- Sorry-free discrete completeness with U and S

This is genuinely novel work with potential for a significant publication.

### 6. Alternative Approaches Considered

**Venema 1993 (BAO/derivation rules approach)**: Proves completeness for well-orderings and ω using orthodox axiom systems. Key idea: axiomatic completeness VIA expressive completeness. Uses Stavi connectives as intermediate step but does NOT provide an independent proof of Stavi's theorem — it takes it from GHR93/GPSS.

**Caleiro/Vigano/Volpe 2013 (Mosaic method)**: Provides decidability and completeness for tense+modal combinations via mosaics. Closest to the project's TM logic (tense + S5). However, mosaic methods give FMP and decidability but don't address expressive completeness or sorry-free integer countermodels.

**Rabinovich 2017 ("A Proof of Stavi's Theorem")**: Provides a SIMPLIFIED proof of Stavi's theorem. Uses composition method (not EF games directly). Could potentially simplify Phase 4 (Corollary 5) but doesn't avoid the core game machinery.

**GHR94 Ch10 separation for integers**: Most promising alternative for the integer-specific case. BUT: the project needs Prior structure completeness (arbitrary discrete orders satisfying Prior axioms), not just ℤ completeness. The separation approach would need to be generalized to Prior structures, which brings back the gap elimination anyway.

**Verdict**: The current GHR93 + Reynolds approach is the RIGHT choice. No alternative avoids the core work.

---

## Strategic Recommendations

### A. Immediate Phase 1 Resolution (h_d_unique)

**CRITICAL**: Abandon the pigeonhole approach. Follow GHR93 Claim 1 literally:
1. C is the rank-r continuation formula (already exists in `cont_holds`)
2. C' = ¬C ∨ K⁻(¬C) has depth r+2 in Lean's stavi_depth
3. The paper's proof is 5 lines — the Lean proof should be ~80-120 lines
4. No density assumption needed
5. The pigeonhole formula is for a DIFFERENT purpose (Section 8 gap detection, not Claim 1)

### B. Phase Ordering and Parallelism

The plan's phase ordering is CORRECT. However:
- **Phases 3-6 CANNOT start before Phase 1** because Phase 3's c-gap-case uses the SplitPointProps infrastructure which depends on h_d_unique
- **Phases 7 and 9 are correctly deprioritized** — they're off the critical path
- **Phase 5 is the cheapest phase** (~2-3 hours) and should be straightforward once Phase 4 delivers stavi_expressive_completeness

### C. Effort Estimate Validation

The plan estimates 38-58 hours total. Based on literature analysis:
- **Phase 1**: 8-12 hours is reasonable IF the Claim 1 proof follows GHR93 literally (not the pigeonhole approach). The main risk is same_order_type sigma/tau (Task 1.6), which should be unblocked by task 195.
- **Phases 3-4**: 14-24 hours combined. Cases III/IV are mechanical once Lemma 9 is available. Assembly chain is the unknown.
- **Phases 5-6B**: 8-11 hours. Gap elimination is self-contained and well-documented in Reynolds 1994.
- **Phases 8-11**: 2-4 hours. Wiring and verification.

**Total**: 32-51 hours, broadly consistent with the plan's 38-58 hours.

### D. Publication Potential

This formalization would be **the first machine-verified proof of**:
1. Stavi expressive completeness for general linear orders
2. Reynolds gap elimination for Prior structures
3. Expressive completeness of {U,S} over Prior structures
4. Sorry-free discrete completeness of bimodal TM logic

**Recommended venue**: ITP (Interactive Theorem Proving) or LICS (Logic in Computer Science). The LeanLTL paper appeared at ITP 2025, establishing precedent for temporal logic formalization in Lean at this venue.

### E. Lean Best Practices from Literature

From the Obendrauf 2024 and Borel determinacy formalizations:
1. **Use typeclasses for generalization**: The project already does this with MonadicSignature
2. **Well-founded induction for game strategies**: The Borel determinacy formalization shows patterns for formalizing game-theoretic arguments via induction on game construction
3. **Mathlib infrastructure**: `LinearOrder`, `ConditionallyCompleteLattice` (for infima), `DenselyOrdered` are all available. The project's custom `ExtendedCarrier` with gaps extends beyond Mathlib's built-in types.
4. **Lean's `omega` and `decide` tactics**: Effective for the combinatorial parts (rank arithmetic, finite type cardinalities)

---

## Literature Insights Summary

| Source | Approach | Relevance to Task 155 |
|--------|----------|----------------------|
| GHR93 (1993 conference paper) | EF games, Theorem 6, Claim 1 | **PRIMARY** — what we're implementing |
| GHR94 Vol 1 Ch10 | Syntactic separation | Alternative for ℤ; NOT applicable to Prior structures |
| GHR94 Vol 1 Ch9 | Basic concepts, definitions | Background only |
| Reynolds 1994 §6-7 | Gap elimination (Lemmas 6-14) | **PRIMARY** — Phases 5-6B |
| Venema 1993 | Orthodox axiomatization via exp. comp. | Validates overall approach |
| Rabinovich 2017 | Simplified Stavi proof | Potential simplification for Phase 4 |
| Caleiro et al. 2013 | Mosaic method for tense+modal | Not applicable (different goal) |
| LeanLTL (ITP 2025) | LTL framework in Lean 4 | Shows feasibility; different scope |
| Obendrauf 2024 | Coalition logic in Lean 4 | Best practices for modal logic |

---

## Confidence Assessment

- **Literature analysis**: HIGH — I've read all relevant sources and cross-referenced approaches
- **Phase 1 resolution (Claim 1)**: HIGH — the GHR93 proof is explicit and the pigeonhole detour is a codebase artifact, not from the paper
- **Phase ordering**: HIGH — dependencies are correctly captured in the plan
- **Effort estimates**: MEDIUM — dependent on implementation surprises in Lean's type system
- **Publication potential**: HIGH — genuinely novel formalization with clear venue targets
- **Alternative approaches**: HIGH confidence they should NOT be pursued — the current approach is correct
